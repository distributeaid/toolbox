FROM elixir:1.10.3-alpine
ARG AUTH=enable
ARG DASHBOARD=enable
ARG GRAPHIQL=enable
RUN apk add build-base curl imagemagick inotify-tools 

RUN mkdir -p /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force