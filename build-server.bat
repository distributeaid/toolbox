@echo off
rem set local dev variables
set DA_POSTGRES_VERSION=11.2
set DA_DB_USERNAME=toolbox
set DA_DB_PASSWORD=1312
set DA_DB_DATABASE=toolbox_dev
set DA_DB_PORT=55432

rem specify database hostname variables
set DA_DB_HOSTNAME_DEV=db
set DA_DB_HOSTNAME_TEST=dbtest

rem Windows-specific Docker configuration
set DA_EXTERNAL_VOLUME_REQUIRED=true
set DA_DB_VOLUME_NAME=db
docker volume create --name db -d local

rem bring up containers
if "%~1"=="-v" (
  docker-compose --verbose up
) else (
  docker-compose up
)
