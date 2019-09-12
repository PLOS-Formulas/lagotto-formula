{% from "lagotto/map.jinja" import props with context %}
{% from "consul/lib.sls" import consul_service_domain, consul_service_definition %}

{% set sidekiq_server = props.get('sidekiq_server', 'None') %}
{% set oscodename = salt.grains.get('oscodename') %}

include:
  - lagotto.nginx
  - lagotto.common
  - lagotto.lib.docker-common

{% set environment = salt.grains.get('environment') %}
{% set app_name = 'lagotto' %}
{% set app_port = props.get('app_port') %}
{% set ip_local_port_range = props.get('sysctl_ip_local_port_range') %}
{% set tcp_tw_recycle = props.get('sysctl_tcp_tw_recycle') %}
{% set tcp_tw_reuse = props.get('sysctl_tcp_tw_reuse') %}
{% set app_name = 'lagotto' %}
{% set mysql_host = consul_service_domain("alm-manager-sql", style='soma') %}

{% set docker0 = salt.network.ip_addrs('docker0') %}
{% set docker_dns = '172.17.0.1' if not docker0 else docker0[0] %}
{% set docker_image_name = "plos/{}:{}".format(props.get('docker_image_name'), props.get('docker_image_tag')) %}

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
      - {{ app_name}}-app-container-absent
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

# TODO this stuff can probably go?
lagotto-sysctl-ip-local-port-range:
  sysctl.present:
    - name: net.ipv4.ip_local_port_range
    - value: {{ ip_local_port_range }}

lagotto-sysctl-tcp-tw-reuse:
  sysctl.present:
    - name: net.ipv4.tcp_tw_reuse
    - value: {{ tcp_tw_reuse }}
