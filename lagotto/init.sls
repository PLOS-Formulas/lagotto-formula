{% from 'lib/environment.sls' import environment %}
{% from "lagotto/map.jinja" import props with context %}

{% set sidekiq_server = props.get('sidekiq_server', 'None') %}
{% set oscodename = salt.grains.get('oscodename') %}

include:
  - nginx
  - lagotto.nginx
  - lagotto.common
{% if grains['fqdn'] == sidekiq_server %}
  - lagotto.sidekiq
{% endif %}

{% set app_root = props.get('app_root') %}
{% set ruby_ver = props.get('version_ruby') %}
{% set ip_local_port_range = props.get('sysctl_ip_local_port_range') %}
{% set tcp_tw_recycle = props.get('sysctl_tcp_tw_recycle') %}
{% set tcp_tw_reuse = props.get('sysctl_tcp_tw_reuse') %}

extend:
  apt-repo-plos:
    pkgrepo.managed:
      - require_in:
        - pkg: lagotto-apt-packages

lagotto-service:
  service.running:
    - name: lagotto
    - enable: true
    - require:
      {%- if oscodename == 'trusty' %}
      - file: /etc/init/lagotto.conf
      {%- else %}
      - file: /etc/systemd/system/lagotto.service
      {%- endif %}
    - watch:
      - file: {{ app_root }}/shared/puma.rb

lagotto-apt-packages:
  pkg.installed:
    - pkgs:
        - build-essential
        - libgmp-dev
        - libmysqlclient-dev
        - libssl-dev
        - nodejs: 8.10.0~dfsg-2ubuntu0.2
        {% if oscodename == 'bionic' %}
        - node-gyp
        - nodejs-dev: 8.10.0~dfsg-2ubuntu0.2
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
