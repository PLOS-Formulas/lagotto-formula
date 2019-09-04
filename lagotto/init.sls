{% from "lagotto/map.jinja" import props with context %}
{% from "consul/lib.sls" import consul_service_domain %}

{% set sidekiq_server = props.get('sidekiq_server', 'None') %}
{% set oscodename = salt.grains.get('oscodename') %}

include:
  - nginx
  - docker
  - lagotto.nginx
  - lagotto.common
{% if grains['fqdn'] == sidekiq_server %}
  - lagotto.sidekiq
{% endif %}

{% set environment = salt.grains.get('environment') %}
{% set app_name = 'lagotto' %}
{% set app_port = props.get('app_port') %}
{% set app_root = props.get('app_root') %}
{% set ruby_ver = props.get('version_ruby') %}
{% set ip_local_port_range = props.get('sysctl_ip_local_port_range') %}
{% set tcp_tw_recycle = props.get('sysctl_tcp_tw_recycle') %}
{% set tcp_tw_reuse = props.get('sysctl_tcp_tw_reuse') %}
{% set app_name = 'lagotto' %}

{% set docker0 = salt.network.ip_addrs('docker0') %}
{% set docker_dns = '172.17.0.1' if not docker0 else docker0[0] %}

#{% set docker_image_name = "plos/{}:{}".format(app_name, environment) %}
{% set docker_image_name = "plos/{}:ALM-1045-dockerize-44373c3".format(app_name) %} 
{% set mysql_host = consul_service_domain("alm-manager-sql", style='soma') %}

extend:
  apt-repo-plos:
    pkgrepo.managed:
      - require_in:
        - pkg: lagotto-apt-packages

{{ app_name }}-image:
  docker_image.present:
    - name: {{ docker_image_name }}
    - force: true
    - require:
      - pkg: docker

{{ app_name }}-containers-absent:
  docker_container.absent:
    - onchanges:
      - {{ app_name }}-image
    - force: True
    - names:
      - {{app_name}}-app
      #- {{app_name}}-worker

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
    - require:
      - {{ app_name }}-image
    - command: docker/start.sh {{ mysql_host }}:3306

# TODO probably remove this
lagotto-apt-packages:
  pkg.installed:
    - pkgs:
        - build-essential
        - libgmp-dev
        - libmysqlclient-dev
        - libssl-dev
        - nodejs
        {% if oscodename == 'bionic' %}
        - node-gyp
        - nodejs-dev
        - libssl1.0-dev
        - npm
        {% endif %}

{{ app_root }}:
  file.directory:
    - user: lagotto
    - group: lagotto
    - require:
      - user: lagotto

{{ app_root }}/shared:
  file.directory:
    - user: lagotto
    - group: lagotto
    - require:
      - file: {{ app_root }}

{{ app_root }}/shared/puma.rb:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/puma/puma.rb
    - require:
      - file: {{ app_root }}/shared

{%- if oscodename == 'trusty' %}
/etc/init/lagotto.conf:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/init/lagotto.conf
    - user: root
    - group: root
    - mode: 644
{%- else %}
/etc/systemd/system/lagotto.service:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/systemd/system/lagotto.service
{%- endif %}

/etc/sudoers.d/lagotto:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/sudoers.d/lagotto

/etc/logrotate.d/rails:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/logrotate.d/rails

lagotto-sysctl-ip-local-port-range:
  sysctl.present:
    - name: net.ipv4.ip_local_port_range
    - value: {{ ip_local_port_range }}

{%- if oscodename == 'trusty' %}
lagotto-sysctl-tcp-tw-recycle:
  sysctl.present:
    - name: net.ipv4.tcp_tw_recycle
    - value: {{ tcp_tw_recycle }}
{%- endif %}

lagotto-sysctl-tcp-tw-reuse:
  sysctl.present:
    - name: net.ipv4.tcp_tw_reuse
    - value: {{ tcp_tw_reuse }}

/usr/local/bin/rake:
  file.symlink:
    - target: /opt/rubies/ruby-{{ ruby_ver }}/bin/rake
    - force: True
    - require:
      - pkg: plos-ruby-{{ ruby_ver }}
