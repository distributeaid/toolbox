FROM debian:buster-20200224-slim AS build

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install packages
RUN apt-get update && \
    apt-get -y -q install curl gnupg2 locales git && \
    sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen && \
    locale && \
    curl -sSLO https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && \
    dpkg -i erlang-solutions_2.0_all.deb && \
    apt-get update && \
    apt-get install -y esl-erlang=1:21.3.8.14-1 elixir=1.9.4-1 imagemagick inotify-tools build-essential && \
    echo "\033[0;34mErlang release:\033[0m \033[0;32m" $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell) "\033[0m" && \
    echo "\033[0;34mImageMagick version:\033[0m \033[0;32m" $(convert -version) "\033[0m" # This is installed in one of the base containers

RUN mkdir -p /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force
