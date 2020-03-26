#!/usr/bin/env sh

# set local dev variables
export DA_POSTGRES_VERSION=11.2
export DA_DB_USERNAME=toolbox
export DA_DB_PASSWORD=1312
export DA_DB_DATABASE=toolbox_dev
export DA_DB_PORT=55432

# specify database hostname variables
export DA_DB_HOSTNAME_DEV=db
export DA_DB_HOSTNAME_TEST=dbtest

# needed only for Windows Docker configuration
export DA_EXTERNAL_VOLUME_REQUIRED=false
export DA_DB_VOLUME_NAME=db

# bring up containers
# if [ "$1" != "-v" ]; then
# 	docker-compose up
# else
# 	docker-compose --verbose up
#   fi
