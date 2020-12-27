FROM nginx:1.19.6-alpine

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf
COPY ./conf/tls/nginx.key /etc/nginx/tls/nginx.key
COPY ./conf/tls/nginx.crt /etc/nginx/tls/nginx.crt
COPY ./conf/tls/tls.conf /etc/nginx/tls/tls.conf