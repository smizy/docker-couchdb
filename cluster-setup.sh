#!/bin/bash

# The Cluster Setup Api
# https://github.com/apache/couchdb-documentation/blob/master/src/cluster/setup.rst
#
# cluster-setup.sh couchdb-1.vnet couchdb-2.vnet couchdb-3.vnet

_mime="Content-Type: application/json"
_user="${COUCHDB_ADMIN_USER:-admin}"
_pass="${COUCHDB_ADMIN_PASS}"
_url="http://${_user}:${_pass}@127.0.0.1:5984/_cluster_setup"

set -e

for _host in "$@"; 
do
	_json=$(cat <<- EOJSON
		 {"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "${_user}", "password":"${_pass}", "port": 5984, "remote_node": "${_host}", "remote_current_user": "${_user}", "remote_current_password": "${_pass}" }
EOJSON
	)
	curl -s -X POST -H "${_mime}" "${_url}" -d "${_json}"
	
	_json=$(cat <<- EOJSON
		{"action": "add_node", "host":"${_host}", "port": "5984", "username": "${_user}", "password":"${_pass}"}
EOJSON
	)

	 curl -s -X POST -H "${_mime}" "${_url}" -d "${_json}"

done

curl -s -X POST -H "${_mime}" "${_url}" -d '{"action": "finish_cluster"}'