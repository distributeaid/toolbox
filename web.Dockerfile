FROM debian:buster-20200224-slim

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install packages
RUN apt-get update && \
    apt-get -y -q install curl gnupg2 locales && \
    sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen && \
    locale && \
    curl -sSLO https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && \
    dpkg -i erlang-solutions_2.0_all.deb && \
    curl -sSL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y esl-erlang elixir imagemagick nodejs inotify-tools build-essential && \
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
RUN npm install

WORKDIR /app

CMD ["iex"]