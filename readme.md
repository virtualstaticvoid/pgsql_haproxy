# Docker Example for PostgreSQL Master+Slave and HAProxy

An example of how to run PostgreSQL database master and slaves with streaming replication and with HAProxy to load balance connections over them.

NOTE: Since HAProxy cannot load balance writes to the master and reads to the slave, you must connect directly to the master to perform any modifications if needed and connect to the proxy to load balance reads for high-availability.

## Usage

Docker Compose is used to manage all the moving parts, however, for convience, there is a Makefile which can be used to run the required steps:

Firstly, to build the docker images required:
```
make build
```

Now you run the services:
```
make run
```

To test whether connections can be made to the proxy and each Postgres instance:
```
make test
make pgsqlchk
```

To connect to the Postgres master using `psql` with the password set in the `.env` file (test):
```
psql -h 172.36.5.16 -U postgres
```

To connect to the proxy using `psql` with the password set in the `.env` file (test):
```
psql -h 172.36.5.1 -p 5488 -U postgres
```

You can `watch` the logs files, or `monitor` using the HAProxy stats web page:
```
make watch
make monitor
```

You can run the following script to see that HAProxy is working as expected. This will output `t` or `f` for the recovery mode of Postgres together with the servers IP address.
Note: set the `PGPASSWORD` environment variable to the same password as specified in the `.env` file.

```
export PGPASSWORD="test";
seq 10 | xargs -Iz psql -h 172.36.5.1 -U postgres -d postgres -p 5488 -t -c "select pg_is_in_recovery(), inet_server_addr();"
```

Example output:

```
 t  | 172.36.5.17
 t  | 172.36.5.18
 f  | 172.36.5.16
 t  | 172.36.5.17
 t  | 172.36.5.18
 f  | 172.36.5.16
 t  | 172.36.5.17
 t  | 172.36.5.18
 f  | 172.36.5.16
 t  | 172.36.5.17
```
