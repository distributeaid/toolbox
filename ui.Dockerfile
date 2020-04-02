# Using this Dockerfile to define the react CI environment
FROM node:13.12.0-alpine3.11 AS base

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

# Grab the UI stuff only
COPY ./react_ui /app

RUN npm install && \
    npm install react-scripts && \
    cp src/aws-exports.ci.js src/aws-exports.js && \
    npm run-script build

FROM nginx:1.17.9-alpine

COPY --from=base /app/build /usr/share/nginx/html