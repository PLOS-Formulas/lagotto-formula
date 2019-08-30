{% from "consul/lib.sls" import consul_service_definition %}

include:
  - redis.master

{{ consul_service_definition("alm-manager-redis", port=6379, cluster="alm") }}
