FROM alpine:3.22.4
RUN apk update && apk add mariadb mariadb-client bash
COPY tools/mariadb.sh /usr/local/bin/
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql
RUN chmod +x /usr/local/bin/mariadb.sh
ENTRYPOINT [ "mariadb.sh" ]

# RUN apt-get update -y && apt-get upgrade -y
# RUN apt-get install -y mariadb-server
# RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql
# COPY ./tools/mariadb.sh /mariadb.sh
# RUN chmod +x /mariadb.sh
# ENTRYPOINT ["sh", "/mariadb.sh"]
