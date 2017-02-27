#!/bin/bash

set -e 

if [ "$1" = 'couchdb' ]; then

	COUCHDB_LOCAL_D="${COUCHDB_CONF}/local.d"
	LOCAL_DOCKER_INI="${COUCHDB_LOCAL_D}/docker.ini"

	mkdir -p ${COUCHDB_LOCAL_D}

	if [ ! -s "${COUCHDB_DATA}/_users.couch" ]; then
		: ${COUCHDB_ADMIN_USER:=admin}
		if [ -z "${COUCHDB_ADMIN_PASS}" ]; then
			: ${COUCHDB_ADMIN_PASS:=$(pwgen -s -1 32)}
			echo "GENERATED ADMIN PASSWORD: ${COUCHDB_ADMIN_PASS}"
		fi

		# local.d/*.ini
		cat <<- EOINI > ${COUCHDB_LOCAL_D}/docker.ini
		[admins]
		${COUCHDB_ADMIN_USER} = ${COUCHDB_ADMIN_PASS}
		
		[chttpd]
		bind_address = 0.0.0.0

		[couchdb]
		database_dir = ${COUCHDB_DATA}
		view_index_dir = ${COUCHDB_DATA}
		EOINI

		chown -R couchdb:couchdb "${COUCHDB_HOME}" "${COUCHDB_CONF}" "${COUCHDB_DATA}"
		find "${COUCHDB_HOME}" "${COUCHDB_DATA}" -type d -exec chmod 0770 {} \;
		find "${COUCHDB_CONF}" -type f -exec chmod 0644 {} \;

		# node name
		NODENAME=$(hostname -f)
		sed -ri 's/^-name .*/-name couchdb@'"${NODENAME}"'/' ${COUCHDB_CONF}/vm.args

	fi

	exec su-exec couchdb couchdb

fi

exec "$@"