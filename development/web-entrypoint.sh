#!/usr/bin/env bash

set -ex

mix ecto.create
mix ecto.migrate
mix phx.server