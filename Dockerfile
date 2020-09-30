FROM elixir:1.10.3-alpine AS builder
ARG AUTH=enable
ARG DASHBOARD=enable
ARG GRAPHIQL=enable

RUN apk add git build-base curl imagemagick inotify-tools 

RUN mkdir -p /app
WORKDIR /app
COPY . .

RUN mix local.hex --force && \
    mix local.rebar && \
    mix deps.get && \
    MIX_ENV=prod mix release

FROM elixir:1.10.3-alpine
RUN apk add imagemagick curl

RUN mkdir -p /app
WORKDIR /app

COPY --from=builder /app/_build/prod /app
CMD [ "/app/rel/ferry/bin/ferry", "start" ]
