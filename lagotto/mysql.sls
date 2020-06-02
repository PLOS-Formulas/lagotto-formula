include:
  - percona.common
  - common.repos

{% set mysql_ip = salt.plosutil.get_canonical_ip().rsplit('.', 1)[0] + '.%' %}

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
