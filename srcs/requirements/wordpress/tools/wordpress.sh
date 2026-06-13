#!/bin/bash
set -e

export PHP_MEMORY_LIMIT=512M

sed -i "s/^listen = .*/listen = ${WP_PORT}/" /etc/php84/php-fpm.d/www.conf

if [ "${NGINX_PORT}" = "443" ]; then
    WP_URL="https://${DOMAIN_NAME}"
else
    WP_URL="https://${DOMAIN_NAME}:${NGINX_PORT}"
fi

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    if [ ! -f "/var/www/wordpress/wp-settings.php" ]; then
        wp core download --path=/var/www/wordpress --allow-root
    fi

    wp config create \
        --dbname=$MYSQL_DB \
        --dbuser=$MYSQL_DB_USER \
        --dbpass=$MYSQL_DB_PWD \
        --dbhost=mariadb:${MYSQL_PORT} \
        --path=/var/www/wordpress \
        --allow-root

    wp config set WP_HOME "${WP_URL}" --type=constant --allow-root --path=/var/www/wordpress
    wp config set WP_SITEURL "${WP_URL}" --type=constant --allow-root --path=/var/www/wordpress

    wp core install \
        --url="${WP_URL}" \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USR \
        --admin_password=$WP_ADMIN_PWD \
        --admin_email=$WP_ADMIN_EMAIL \
        --path=/var/www/wordpress \
        --allow-root

    wp user create \
        $WP_USR $WP_EMAIL \
        --user_pass=$WP_PWD \
        --role=contributor \
        --path=/var/www/wordpress \
        --allow-root
fi

echo "starting php-fpm"
exec php-fpm84 -F
