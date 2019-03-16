FROM elixir:1.7.4 AS build-env

ARG DB_USERNAME
ENV DB_USERNAME $DB_USERNAME

ARG DB_PASSWORD
ENV DB_PASSWORD $DB_PASSWORD

ARG DB_DATABASE
ENV DB_DATABASE $DB_DATABASE

ARG DB_HOSTNAME
ENV DB_HOSTNAME $DB_HOSTNAME

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
    echo "Erlang release: " $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell) && \
    echo "Node version: " $(node --version) && \
    echo "NPM version: " $(npm --version) && \
    echo "ImageMagick version: " $(convert -version) # This is installed in one of the base containers

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