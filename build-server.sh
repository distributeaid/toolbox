#!/usr/bin/env bash

# set local dev variables
export DA_POSTGRES_VERSION=11.2
export DA_DB_USERNAME=toolbox
export DA_DB_PASSWORD=1312
export DA_DB_DATABASE=toolbox_dev
export DA_DB_HOSTNAME=db
export DA_DB_PORT=55432

# set test database variables
export DA_DB_DATABASE_TEST=toolbox_test
export DA_DB_HOSTNAME_TEST=dbtest

# bring up containers
docker-compose up