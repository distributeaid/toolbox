# Using this Dockerfile to define the react CI environment
FROM node:13.12.0-alpine3.11

# Update OpenSSL and dumb-init
RUN apk add --no-cache --update openssl dumb-init

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

# Grab the UI stuff only
COPY ./react_ui ./

RUN npm install && \
    npm install react-scripts

# define dumb-init as the entrypoint
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["npm", "start"]
