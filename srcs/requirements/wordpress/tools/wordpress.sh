#!/bin/bash
set -e

export PHP_MEMORY_LIMIT=512M

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    if [ ! -f "/var/www/wordpress/wp-settings.php" ]; then
        wp core download --path=/var/www/wordpress --allow-root
    fi

    wp config create \
        --dbname=$MYSQL_DB \
        --dbuser=$MYSQL_DB_USER \
        --dbpass=$MYSQL_DB_PWD \
        --dbhost=mariadb:3306 \
        --path=/var/www/wordpress \
        --allow-root

    wp core install \
    --url="https://$DOMAIN_NAME" \
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