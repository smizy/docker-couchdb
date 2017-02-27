# docker-couchdb

Apache CouchDB docker image based on alpine

Note that this image is unstable and under testing.

## Cluster setup on single host

```
# build
docker build -t local/couchdb .

# network
docker network create vnet

# set admin pass 
export COUCHDB_ADMIN_PASS=xxxxxxxxxxxxx

# startup couchdb cluster (3 nodes)
docker-compose up -d 

# tail logs for a while (ignore [error] database_does_not_exist..)
docker-compose logs -f 

# check ps
docker-compose ps
  Name                 Command               State                           Ports                         
----------------------------------------------------------------------------------------------------------
couchdb-1   /sbin/tini -- entrypoint.s ...   Up      4369/tcp, 0.0.0.0:5984->5984/tcp, 5986/tcp, 9100/tcp 
couchdb-2   /sbin/tini -- entrypoint.s ...   Up      4369/tcp, 5984/tcp, 5986/tcp, 9100/tcp                
couchdb-3   /sbin/tini -- entrypoint.s ...   Up      4369/tcp, 5984/tcp, 5986/tcp, 9100/tcp

# cluster setup
docker exec -it couchdb-1 cluster-setup.sh couchdb-1.vnet couchdb-2.vnet couchdb-3.vnet
{"ok":true}
{"error":"conflict","reason":"Document update conflict."} 
{"ok":true}
{"ok":true}
{"ok":true}
{"ok":true}
{"ok":true}

# open admin page / verify
* open http://localhost:5984/_utils
* login 
* select [Verify] on left menu 
* do [Veriy Installation] 
TODO: Replication often failed.

# stop couchdb cluster  
docker-compose stop

# cleanup container 
docker-compose rm -v
```
