# Using this Dockerfile to define the react CI environment

FROM node:13.12.0-alpine3.11

# Update OpenSSL and dumb-init
RUN apk update && apk add --update openssl dumb-init

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

# Grab the UI stuff only
COPY ./react_ui ./

RUN npm install
RUN npm install react-scripts -g 

# define dumb-init as the entrypoint
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["npm", "start"] 