#!/usr/bin/env bash

set -ex

mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server

