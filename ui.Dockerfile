# Using this Dockerfile to define the react CI environment

FROM node:alpine:13.12.0-alpine3.11

# Update OpenSSL
RUN apk update && apk add --update openssl  

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

COPY ./ ./

RUN npm install
RUN npm install react-scripts -g 

CMD ["npm", "start"] 