{% from "lagotto/map.jinja" import props with context %}

{% set app_port = props.get('app_port') %}
{% set docker0 = salt.network.ip_addrs('docker0') %}
{% set docker_dns = '172.17.0.1' if not docker0 else docker0[0] %}
{% set app_name = 'lagotto' %}

{% set docker_image_name = "plos/{}:{}".format(props.get('docker_image_name'), props.get('docker_image_tag')) %} 

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