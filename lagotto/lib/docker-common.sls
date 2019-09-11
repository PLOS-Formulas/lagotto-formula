
{% from "lagotto/map.jinja" import props with context %}

{% set app_name = 'lagotto' %}
{% set docker0 = salt.network.ip_addrs('docker0') %}
{% set docker_dns = '172.17.0.1' if not docker0 else docker0[0] %}
{% set docker_image_name = "plos/{}:{}".format(props.get('docker_image_name'), props.get('docker_image_tag')) %} 

include:
  - docker

{{ app_name }}-image:
  docker_image.present:
    - name: {{ docker_image_name }}
    - force: true
    - require:
      - pkg: docker
