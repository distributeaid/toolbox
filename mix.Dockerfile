FROM elixir:1.10.4-alpine
ARG AUTH=enable
ARG DASHBOARD=enable
ARG GRAPHIQL=enable
RUN apk add git build-base curl imagemagick inotify-tools 

RUN mkdir -p /app
WORKDIR /app
RUN wget https://raw.githubusercontent.com/eficode/wait-for/master/wait-for; chmod +x wait-for; mv wait-for /bin
RUN mix local.hex --force && \
    mix local.rebar --force