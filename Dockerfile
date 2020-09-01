FROM elixir:1.10.3-alpine AS builder
RUN apk add build-base curl imagemagick inotify-tools 
#RUN apk add apt-utils debconf make build-essential curl gnupg2 locales locales-all git imagemagick inotify-tools

#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8
#ENV LC_CTYPE en_US.UTF-8
#RUN locale-gen en_US.UTF-8

RUN mkdir -p /app
WORKDIR /app
COPY . .

RUN mix local.hex --force && \
    mix local.rebar && \
    mix deps.get && \
    MIX_ENV=prod mix release

FROM elixir:1.10.3-alpine
RUN apk add imagemagick curl

#ENV LANG en_US.UTF-8
#ENV LC_ALL en_US.UTF-8
##ENV LANGUAGE en_US:en
#ENV LC_CTYPE en_US.UTF-8
#RUN locale-gen en_US.UTF-8

RUN mkdir -p /app
WORKDIR /app

COPY --from=builder /app/_build/prod /app
CMD [ "/app/rel/ferry/bin/ferry", "start" ]
