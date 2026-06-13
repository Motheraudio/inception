#!/bin/bash

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql
  mariadbd --user=mysql --bootstrap <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_DB_USER}\`@\'%\' IDENTIFIED BY \'${MYSQL_DB_PWD}\';
GRANT ALL ON \`${MYSQL_DB}\`.* TO \`${MYSQL_DB_USER}\`@\'%\';
FLUSH PRIVILEGES;
EOF
fi
exec mariadbd --user=mysql --bind-address=0.0.0.0 --port=3306
