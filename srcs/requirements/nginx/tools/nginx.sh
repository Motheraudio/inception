#!/bin/bash
set -e

mkdir -p /run/nginx /etc/nginx/ssl /var/www/html

if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=AT/ST=Vienna/L=Vienna/O=42/OU=Inception/CN=alvcampo.42.fr"
fi

cat << 'EOF' > /etc/nginx/nginx.conf
events {}

http {
    include /etc/nginx/mime.types;

    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name alvcampo.42.fr;

        ssl_protocols TLSv1.3;
        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        root /var/www/wordpress;
        index index.php;

        location ~ \.php$ {
            fastcgi_pass wordpress:9000;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
}
EOF

exec nginx -g 'daemon off;'