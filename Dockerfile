FROM alpine:3.5

ENV COUCHDB_VERSION   2.0.0
ENV COUCHDB_HOME      /usr/local/couchdb
ENV COUCHDB_CONF      ${COUCHDB_HOME}/etc
ENV COUCHDB_DATA      /var/lib/couchdb

ENV PATH              $PATH:${COUCHDB_HOME}/bin

RUN set -x \
    ## libmozjs185 
    ## - dependencies
    && apk update \
    && apk --no-cache add \
        nspr \
     && apk --no-cache add --virtual .builddeps \
        build-base \
        m4 \
        nspr-dev \
        perl \ 
        python \
        zip \
    ## - autoconf 2.13
    && wget -q -O - http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz \
        | tar -xzf - -C /tmp \
    && cd /tmp/autoconf* \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && wget -q -O - http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz \
        | tar -xzf - -C /tmp \
    && cd /tmp/js-1.8.5/js/src \
    ## - build 
    ## - disable #pragma visibility
    && sed -ri 's/ac_cv_have_visibility_builtin_bug=no/ac_cv_have_visibility_builtin_bug=yes/' configure.in \
    && autoconf \
    && mkdir build_OPT.OBJ \
    && cd build_OPT.OBJ \
    && CXXFLAGS="--std=gnu++98" ../configure --prefix=/usr \
    && make \
    && make install \
    ## - clean
    && cd /tmp \
    && rm -rf \
        /usr/local/bin/autoconf \
        /usr/local/share/autoconf \
        /usr/local/info \
        /tmp/autoconf* \
        /tmp/js-1.8* \

    ## couchdb 
    ## - dependencies
    && apk --no-cache add \
        bash \
        curl \
        erlang \
        erlang-asn1 \       
        erlang-crypto \
        erlang-erts \
        erlang-inets \
        erlang-os-mon \
        erlang-public-key \
        erlang-runtime-tools \
        erlang-sasl \
        erlang-ssl \
        erlang-syntax-tools \
        erlang-xmerl \
        help2man \
        icu-libs \
        pwgen \
        su-exec \
        tini \
    && apk --no-cache add --virtual .builddeps.1 \
        build-base \
        curl-dev \
        erlang-dev \
        erlang-eunit \
        erlang-reltool \
        erlang-syntax-tools \
        erlang-tools \
        git \
        icu-dev \
    && mirror_url=$( \
        wget -q -O - "http://www.apache.org/dyn/closer.cgi/?as_json=1" \
        | grep "preferred" \
        | sed -n 's#.*"\(http://*[^"]*\)".*#\1#p' \
        ) \ 
    && wget -q -O - ${mirror_url}/couchdb/source/${COUCHDB_VERSION}/apache-couchdb-${COUCHDB_VERSION}.tar.gz \
        | tar -xzf - -C /tmp \
    ## - build
    && cd /tmp/apache-* \
    && ./configure --disable-docs \
    && make release \
    && cp -r rel/couchdb /usr/local/ \
    ## - clean
    && apk del \
        .builddeps \
        .builddeps.1 \
    && rm -rf /tmp/apache-* \
    ## user/dir/permmsion
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && adduser -D  -g '' -s /sbin/nologin couchdb \
    && mkdir -p ${COUCHDB_DATA} 

COPY  entrypoint.sh cluster-setup.sh /usr/local/bin/

WORKDIR ${COUCHDB_HOME}

VOLUME ["${COUCHDB_DATA}"]

EXPOSE 5984 5986 4369 9100

ENTRYPOINT ["/sbin/tini", "--", "entrypoint.sh"]
CMD ["couchdb"]

