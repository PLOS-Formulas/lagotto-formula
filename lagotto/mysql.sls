include:
  - percona.common
  - common.repos

{% from 'lib/network.sls' import bind_ip0 with context %}

{% set mysql_ip = bind_ip0().rsplit('.', 1)[0] + '.%' %}

lagotto_db:
  mysql_database.present:
    - name: lagotto
  mysql_user.present:
    - name: 'lagotto'
    - host: {{ mysql_ip }}
    - password: {{ pillar['secrets']['lagotto']['mysql']['password'] }}
  mysql_grants.present:
    - database: lagotto.*
    - grant: ALL PRIVILEGES
    - user: lagotto
    - host: {{ mysql_ip }}

lagotto_localhost:
  mysql_user.present:
    - name: 'lagotto'
    - host: 127.0.0.1
    - password: {{ pillar['secrets']['lagotto']['mysql']['password'] }}
  mysql_grants.present:
    - database: lagotto.*
    - grant: ALL PRIVILEGES
    - user: lagotto
    - host: 127.0.0.1 
