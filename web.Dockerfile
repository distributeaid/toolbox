FROM elixir:1.10.3-slim AS builder
RUN apt-get update && apt-get -y -q install apt-utils debconf make build-essential curl gnupg2 locales locales-all git imagemagick inotify-tools

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8

RUN mkdir -p /app
WORKDIR /app
COPY . .

RUN mix local.hex --force && \
    mix local.rebar && \
    mix deps.get && \
    MIX_ENV=prod mix release

FROM elixir:1.10.3-slim

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8

RUN mkdir -p /app
WORKDIR /app

COPY --from=build /app/_build/prod /app

CMD [ "/app/rel/ferry/bin/ferry", "start" ]
