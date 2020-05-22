{% from "consul/lib.sls" import consul_service_definition %}

include:
  - percona.common
  - common.repos

{% set mysql_ip = salt.plosutil.get_canonical_ip().rsplit('.', 1)[0] + '.%' %}

{{ consul_service_definition("alm-manager-sql", port=3306, cluster="alm") }}

{% set docker_ip = '172.16.0.0/255.240.0.0' %}

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
    - host: {{ docker_ip }}
    - password: {{ pillar['secrets']['lagotto']['mysql']['password'] }}
  mysql_grants.present:
    - database: alm.*
    - grant: ALL PRIVILEGES
    - user: alm
    - host: {{ docker_ip }}
