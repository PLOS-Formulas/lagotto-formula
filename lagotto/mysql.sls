{% from "consul/lib.sls" import consul_service_definition %}

include:
  - percona.common
  - common.repos

{% set mysql_ip = salt.plosutil.get_canonical_ip().rsplit('.', 1)[0] + '.%' %}

{{ consul_service_definition("alm-manager-sql", port=3306, cluster="alm") }}

# TODO don't hardcode this (can I use CIDR here?)
{% set docker_ip = '172.17.0.2' %}

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
    - host: {{ docker_ip }}
    - password: {{ pillar['secrets']['lagotto']['mysql']['password'] }}
  mysql_grants.present:
    - database: lagotto.*
    - grant: ALL PRIVILEGES
    - user: lagotto
    - host: {{ docker_ip }}
