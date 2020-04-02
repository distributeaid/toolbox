FROM nginx:1.17.9-alpine

COPY etc/nginx/conf.d /etc/nginx/conf.d
COPY react_ui/build /usr/share/nginx/html

EXPOSE 80 443