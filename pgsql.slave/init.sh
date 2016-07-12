#!/bin/bash
set -e

# this script is executed by the initialization routine of the postgres docker container

# See https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/ for why `gosu` is used

export PGPASSWORD="$POSTGRES_PASSWORD"

# nb: need to stop service
gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop

# delete the contents of data directory
pushd "$PGDATA"
rm -rf *
popd

# create base backup from the master
# and receive into our data directory
gosu postgres pg_basebackup -h postgres_master \
                            -U pgsqlrepusr \
                            -D "$PGDATA" \
                            -v -P --xlog-method=stream

# configure as a slave
cp -avr /usr/share/postgresql/9.4/recovery.conf.sample $PGDATA/recovery.conf
echo "standby_mode = on" >> $PGDATA/recovery.conf
echo "primary_conninfo = 'host=postgres_master port=5432 user=pgsqlrepusr password=$POSTGRES_PASSWORD'" >> $PGDATA/recovery.conf
echo "hot_standby = on" >> $PGDATA/postgresql.conf

# start service
gosu postgres pg_ctl -D "$PGDATA" -m fast -w start
