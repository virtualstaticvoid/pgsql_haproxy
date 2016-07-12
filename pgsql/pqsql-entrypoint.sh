#!/bin/bash

# for monitoring postgres
service xinetd start

# call original container entrypoint
/docker-entrypoint.sh "$@"
