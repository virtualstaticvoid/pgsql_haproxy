#!/bin/bash
set -e

# this script is executed by the initialization routine of the postgres docker container

# create the replication user
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE ROLE pgsqlrepusr WITH PASSWORD '$POSTGRES_PASSWORD' LOGIN REPLICATION CONNECTION LIMIT 5;
EOSQL

# fix up directory permissions
chown -R postgres "$PGARCHIVE"

# write replication configuration entries
echo "host replication pgsqlrepusr 0.0.0.0/0 trust" >> "$PGDATA/pg_hba.conf"

echo "wal_level = hot_standby"  >> "$PGDATA/postgresql.conf"
echo "archive_mode = on"        >> "$PGDATA/postgresql.conf"
echo "archive_command = 'test ! -f $PGARCHIVE/%f && cp %p $PGARCHIVE/%f'" >> "$PGDATA/postgresql.conf"
echo "max_wal_senders = 3"      >> "$PGDATA/postgresql.conf"
