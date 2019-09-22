#!/usr/bin/env bash

set -ex

mix deps.get
mix ecto.create
mix ecto.migrate
cd assets && npm install && cd ..
mix phx.server

