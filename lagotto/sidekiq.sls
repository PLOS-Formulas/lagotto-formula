{% from "lagotto/map.jinja" import props with context %}

{% set app_name = 'lagotto' %}
{% set docker0 = salt.network.ip_addrs('docker0') %}
{% set docker_dns = '172.17.0.1' if not docker0 else docker0[0] %}
{% set docker_image_name = "plos/{}:{}".format(props.get('docker_image_name'), props.get('docker_image_tag')) %}

include:
  - lagotto.lib.docker-common

{{ app_name }}-worker-container-absent:
  docker_container.absent:
    - onchanges:
      - {{ app_name }}-image
    - force: True
    - names:
      - {{app_name}}-worker

{{ app_name }}-worker-container-running:
  docker_container.running:
    - name: {{ app_name }}-worker
    - image: {{ docker_image_name }}
    - environment:
{%- for name, value in props.items() %}
        {{ name|upper }}: {{ value }}
{% endfor %}
    - dns: {{ docker_dns }}
    - require:
      - {{ app_name }}-image
    - command: bundle exec sidekiq