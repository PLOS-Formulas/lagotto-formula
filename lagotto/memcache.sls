{% from "consul/lib.sls" import consul_service_definition %}

{{ consul_service_definition("alm-manager-memcache", port=5984, cluster="alm") }}

include:
  - memcache 

extend:
  /etc/memcached.conf:
    file:
      - context:
        addy_bind: 127.0.0.1,{{ salt.plosutil.get_canonical_ip() }}
