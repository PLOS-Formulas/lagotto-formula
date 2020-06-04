{% from "lagotto/map.jinja" import props with context %}
{% from "consul/lib.sls" import consul_service_domain, consul_service_definition %}
{% from "lagotto/lib/docker-common.sls" import app_name, docker_dns, docker_image_name %}


{% set sidekiq_server = props.get('sidekiq_server', 'None') %}
{% set oscodename = salt.grains.get('oscodename') %}

include:
  - lagotto.nginx
  - lagotto.common
  - lagotto.lib.docker-common

{% set environment = salt.grains.get('environment') %}
{% set app_port = props.get('app_port') %}
{% set mysql_host = consul_service_domain("alm-manager-sql", style='soma') %}

{{ app_name }}-app-container-absent:
  docker_container.absent:
    - onchanges:
      - {{ app_name }}-image
    - force: True
    - names:
      - {{app_name}}-app

{{ app_name }}-network:
  docker_network.present:
    - name: {{ app_name }}

{{ app_name }}-app-container-running:
  docker_container.running:
    - name: {{ app_name }}-app
    - image: {{ docker_image_name }}
    - environment:
{%- for name, value in props.items() %}
        {{ name|upper }}: {{ value }}
{% endfor %}
    - dns: {{ docker_dns }}
    - port_bindings:
      - {{ app_port }}:{{ app_port }}
    - binds:
      - {{ app_name }}-railsassets:/code/public
    - networks:
      - {{ app_name }}
    - require:
      - {{ app_name }}-image
      - {{ app_name }}-network
      - {{ app_name }}-assets-volume
    - command: docker/start.sh {{ mysql_host }}:3306

{{ app_name }}-assets-volume-absent:
  docker_volume.absent:
    - onchanges:
      - {{ app_name }}-image
    - require:
      - {{ app_name }}-app-container-absent
      - {{ app_name }}-web-container-absent
    - name: {{ app_name }}-railsassets
    - onlyif:
      - docker inspect {{ app_name }}-railsassets > /dev/null

{{ app_name }}-assets-volume:
  docker_volume.present:
    - name: {{ app_name }}-railsassets

{{ consul_service_definition("alm-manager-app", 
                             port=app_port, 
                             health_check_http_path="/",
                             cluster="alm") }}
