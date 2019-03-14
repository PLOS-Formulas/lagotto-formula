# only lagotto full-stack, single-node deployments should need to use this state.
#
# CouchDB only supports binding to single or all interfaces (ie, not selective)
# https://github.com/apache/couchdb/issues/1589
{% if salt.grains.get('oscodename') == 'trusty' %}
  {% set couchdb_ini = '/etc/couchdb/default.ini' %}
{% else %}
  {% set couchdb_ini = '/opt/couchdb/etc/local.ini' %}
{% endif %}
include:
  - couchdb 

extend:
  {{ couchdb_ini }}:
    file:
      - context:
        b_address: 0.0.0.0 
