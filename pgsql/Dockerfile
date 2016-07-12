FROM postgres:9.4.5

ENV PGARCHIVE /var/lib/postgresql/archive

##
# health check using xinetd and a script
#
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    xinetd \
  && rm -rf /var/lib/apt/lists/*

COPY pgsqlchk /opt/pgsqlchk
RUN chmod 777 /opt/pgsqlchk

COPY xinetd_pgsqlchk /etc/xinetd.d/pgsqlchk
RUN echo "pgsqlchk 23267/tcp" >> /etc/services

##
# postgres initialization script
#
ONBUILD COPY init.sh /docker-entrypoint-initdb.d/init.sh

##
# override entry point, so xinetd service can be started before postgres
#
COPY pqsql-entrypoint.sh /
ENTRYPOINT ["/pqsql-entrypoint.sh"]
CMD ["postgres"]
