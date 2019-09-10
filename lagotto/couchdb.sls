# only lagotto full-stack, single-node deployments should need to use this state.
#
# CouchDB only supports binding to single or all interfaces (ie, not selective)
# https://github.com/apache/couchdb/issues/1589
{% set couchdb_ini = '/opt/couchdb/etc/local.ini' %}
include:
  - couchdb 

extend:
  {{ couchdb_ini }}:
    file:
      - context:
        b_address: 0.0.0.0 
