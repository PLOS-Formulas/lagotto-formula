{% from "consul/lib.sls" import consul_service_definition %}
{% from "lagotto/map.jinja" import props with context %}
{% from "lagotto/lib/docker-common.sls" import app_name, docker_dns %}

{% set app_port = props.get('app_port') %}

# nginx is now run in a container instead of on the host
remove-nginx:
  pkg.removed:
    - name: nginx

stop-nginx:
  service.disabled:
    - name: nginx

{{ app_name }}-nginx-conf-file:
  file.managed:
    - name: /opt/{{ app_name }}/conf/etc/nginx/nginx.conf
    - source: salt://{{ app_name }}/conf/etc/nginx/nginx.conf
    - template: jinja
    - mode: 0644
    - makedirs: True
    - defaults:
        app_domain: {{ app_name }}-app
        app_port: {{ app_port }}

{{ app_name }}-web-container-absent:
  docker_container.absent:
    - onchanges:
      - {{ app_name }}-image
    - force: True
    - names:
      - {{app_name}}-web

{{ app_name }}-web-container-running:
  docker_container.running:
    - name: {{ app_name }}-web
    - image: nginxinc/nginx-unprivileged:1.16-alpine
    - port_bindings:
      - 80:8080
    - networks:
      - {{ app_name }}
    - dns: {{ docker_dns }}
    - binds:
      - {{ app_name }}-railsassets:/code/public
      - /opt/{{ app_name }}/conf/etc/nginx/nginx.conf:/etc/nginx/nginx.conf
    - require:
      - {{ app_name }}-nginx-conf-file
      - {{ app_name }}-network
      - {{ app_name }}-assets-volume
      - stop-nginx

{{ consul_service_definition("alm-manager-web", 
                             port=80,  
                             health_check_http_path="/", 
                             cluster="alm") }}