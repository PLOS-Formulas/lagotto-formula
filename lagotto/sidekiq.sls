{% from "lagotto/map.jinja" import props with context %}
{% from "lagotto/lib/docker-common.sls" import app_name, docker_dns, docker_image_name %}

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