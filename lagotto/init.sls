{% from "lagotto/map.jinja" import props with context %}
{% from "consul/lib.sls" import consul_service_domain %}

{% set sidekiq_server = props.get('sidekiq_server', 'None') %}
{% set oscodename = salt.grains.get('oscodename') %}

include:
  - docker
  - lagotto.nginx
  - lagotto.common

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

{% set docker_image_name = "plos/{}:{}".format(props.get('docker_image_name'), props.get('docker_image_tag')) %} 
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
      - {{app_name}}-worker

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
      - {{ app_name}}-containers-absent
    - name: {{ app_name }}-railsassets

{{ app_name }}-assets-volume:
  docker_volume.present:
    - name: {{ app_name }}-railsassets


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
