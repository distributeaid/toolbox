# Using this Dockerfile to define the react CI environment

FROM node:alpine

# Force https
# RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories

# Update OpenSSL
RUN apk update && apk add --update openssl  

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

COPY ./ ./

# RUN npm install
# RUN npm install react-scripts -g 

# CMD ["npm", "start"] 