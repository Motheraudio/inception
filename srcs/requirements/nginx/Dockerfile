FROM alpine:3.23.0
RUN apk update && apk add nginx openssl bash
COPY tools/nginx.sh /usr/local/bin/
RUN mkdir -p /run/nginx && chown -R nginx:nginx /run/nginx
RUN chmod +x /usr/local/bin/nginx.sh
ENTRYPOINT [ "/usr/local/bin/nginx.sh" ]