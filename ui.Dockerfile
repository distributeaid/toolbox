FROM node:alpine

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

COPY ./ ./

RUN npm install
RUN npm install react-scripts -g 

CMD ["npm", "start"] 