{% from 'lib/environment.sls' import environment %}
{% set sidekiq_server = salt['pillar.get']('environment:' ~ environment ~ ':lagotto:sidekiq_server', 'None') %}

include:
  - nginx
  - lagotto.nginx
  - lagotto.common
{% if grains['fqdn'] == sidekiq_server %}
  - lagotto.sidekiq
{% endif %}

{% set app_root = pillar['lagotto']['deploy']['app_root'] %}
{% set ruby_ver = pillar['lagotto']['versions']['ruby'] %}
{% set ip_local_port_range = pillar['lagotto']['sysctl']['ip_local_port_range'] %}
{% set tcp_tw_recycle = pillar['lagotto']['sysctl']['tcp_tw_recycle'] %}
{% set tcp_tw_reuse = pillar['lagotto']['sysctl']['tcp_tw_reuse'] %}

extend:
  apt-repo-plos:
    pkgrepo.managed:
      - require_in:
        - pkg: lagotto-apt-packages
        - pkg: chruby
        - pkg: plos-ruby

lagotto-service:
  service.running:
    - name: lagotto
    - enable: true
    - require:
      - file: /etc/init/lagotto.conf
    - watch:
      - file: {{ app_root }}/shared/puma.rb

lagotto-apt-packages:
  pkg.installed:
    - pkgs:
        - build-essential
        - libgmp-dev
        - libmysqlclient-dev
        - libssl-dev
        - nodejs

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

/etc/init/lagotto.conf:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/init/lagotto.conf
    - user: root
    - group: root
    - mode: 644

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

lagotto-sysctl-tcp-tw-recycle:
  sysctl.present:
    - name: net.ipv4.tcp_tw_recycle
    - value: {{ tcp_tw_recycle }}

lagotto-sysctl-tcp-tw-reuse:
  sysctl.present:
    - name: net.ipv4.tcp_tw_reuse
    - value: {{ tcp_tw_reuse }}

/usr/local/bin/rake:
  file.symlink:
    - target: /opt/rubies/ruby-{{ ruby_ver }}/bin/rake
    - force: True
    - require:
      - pkg: plos-ruby 
