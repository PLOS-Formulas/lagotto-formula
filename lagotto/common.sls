{% from 'lib/auth_keys.sls' import manage_authorized_keys %}
{% from 'lib/environment.sls' import environment %}
{% from "lib/ruby.sls" import use_ruby -%}

{% from "lagotto/map.jinja" import props with context %}

{% set capdeloy_host = salt['pillar.get']('environment:' ~ environment ~ ':capdeploy', 'None') %}

include:
  - common.packages
  - common.repos
  - lib.ruby

{% set ruby_ver = props.get('version_ruby') %}

{{ use_ruby(version=ruby_ver, user='lagotto', bundler_version='1.17.3') }}

lagotto:
    group:
      - present
      - gid: {{ salt.pillar.get('uids:lagotto:gid') }}
    user:
      - present
      - uid: {{ salt.pillar.get('uids:lagotto:uid') }}
      - gid: {{ salt.pillar.get('uids:lagotto:gid') }}
      - gid_from_name: true
{% if grains['fqdn'] == capdeloy_host %}
      - groups:
        - teamcity
{% endif %}
      - createhome: true
      - shell: /bin/bash
      - require:
        - group: lagotto
{% if grains['fqdn'] == capdeloy_host %}
        - group: teamcity
{% endif %}


{% if 'is_vagrant' in grains or grains['environment'] == 'dev' %}
{{ manage_authorized_keys('/home/lagotto/.ssh', 'lagotto', pillar['lagotto']['deployers'][grains['environment']], pillar['lagotto']['deploy_keys'][grains['environment']]) }}
{% else %}
{{ manage_authorized_keys('/home/lagotto/.ssh', 'lagotto', ssh_extra=pillar['lagotto']['deploy_keys'][grains['environment']]) }}
{% endif %}

/home/lagotto/.bashrc:
  file.managed:
    - template: jinja
    - source: salt://lagotto/home/lagotto/bashrc

/home/lagotto/.bash_profile:
  file.managed:
    - source: salt://lagotto/home/lagotto/bash_profile

{% if grains['environment'] in ['vagrant', 'dev', 'qa'] %}

/home/lagotto/db/seeds:
  file.directory:
    - user: lagotto
    - group: lagotto
    - makedirs: true
    - require:
      - user: lagotto

/home/lagotto/db/seeds/sources.rb:
  file.managed:
    - template: jinja
    - source: salt://lagotto/home/lagotto/db/seeds/sources.rb
    - mode: 600
    - user: lagotto
    - group: lagotto

{% endif %}
