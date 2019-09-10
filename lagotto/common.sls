{% from 'lib/auth_keys.sls' import manage_authorized_keys %}
{% from 'lib/environment.sls' import environment %}

{% from "lagotto/map.jinja" import props with context %}

include:
  - common.packages
  - common.repos

lagotto:
    group:
      - present
      - gid: {{ salt.pillar.get('uids:lagotto:gid') }}
    user:
      - present
      - uid: {{ salt.pillar.get('uids:lagotto:uid') }}
      - gid: {{ salt.pillar.get('uids:lagotto:gid') }}
      - gid_from_name: true
      - createhome: true
      - shell: /bin/bash
      - require:
        - group: lagotto

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
    - source: salt://lagotto/conf/home/lagotto/db/seeds/sources.rb
    - mode: 600
    - user: lagotto
    - group: lagotto

{% endif %}
