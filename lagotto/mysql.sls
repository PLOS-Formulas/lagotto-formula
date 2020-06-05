include:
  - percona.common
  - common.repos

{% set mysql_ip = salt.plosutil.get_canonical_ip().rsplit('.', 1)[0] + '.%' %}

lagotto_db:
  mysql_database.present:
    - name: alm
  mysql_user.present:
    - name: 'alm'
    - host: {{ mysql_ip }}
    - password: {{ pillar['secrets']['lagotto']['mysql']['password'] }}
  mysql_grants.present:
    - database: alm.*
    - grant: ALL PRIVILEGES
    - user: alm
    - host: {{ mysql_ip }}

lagotto_localhost:
  mysql_user.present:
    - name: 'alm'
    - host: 127.0.0.1
    - password: {{ pillar['secrets']['lagotto']['mysql']['password'] }}
  mysql_grants.present:
    - database: alm.*
    - grant: ALL PRIVILEGES
    - user: alm
    - host: 127.0.0.1
