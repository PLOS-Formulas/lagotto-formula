# only lagotto full-stack, single-node deployments should need to use this state.
#
# CouchDB only supports binding to single or all interfaces (ie, not selective)
# https://issues.apache.org/jira/browse/COUCHDB-907

include:
  - couchdb 

extend:
  /etc/couchdb/default.ini:
    file:
      - context:
        b_address: 0.0.0.0 
