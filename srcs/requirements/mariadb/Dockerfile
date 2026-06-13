FROM alpine:3.23.0
RUN apk update && apk add mariadb mariadb-client bash
COPY tools/mariadb.sh /usr/local/bin/
COPY conf/mariadb-server.cnf /etc/my.cnf.d/
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql
RUN chmod +x /usr/local/bin/mariadb.sh
ENTRYPOINT [ "mariadb.sh" ]