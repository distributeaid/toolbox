FROM elixir:1.7.4 AS build-env

# For getting NPM - not included by default in Debian
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get install -y esl-erlang && \
    apt-get install -y nodejs && \
    apt-get install -y npm && \
    apt-get install -y build-essential && \
    apt-get install -y inotify-tools && \
    echo "\033[0;34mErlang release:\033[0m \033[0;32m" $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell) "\033[0m" && \
    echo "\033[0;34mNode version:\033[0m \033[0;32m" $(node --version) "\033[0m" && \
    echo "\033[0;34mNPM version:\033[0m \033[0;32m" $(npm --version) "\033[0m" && \
    echo "\033[0;34mImageMagick version:\033[0m \033[0;32m" $(convert -version) "\033[0m" # This is installed in one of the base containers

RUN mkdir -p /app

WORKDIR /app
COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.update postgrex && \
    mix deps.compile

WORKDIR /app/assets
RUN npm install && node node_modules/brunch/bin/brunch build

WORKDIR /app