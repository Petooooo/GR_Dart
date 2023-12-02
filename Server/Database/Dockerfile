FROM mysql:8.1.0
ENV  MYSQL_ROOT_PASSWORD=root
ENV  MYSQL_DATABASE=password
ADD  ./init_db/* /docker-entrypoint-initdb.d
EXPOSE 3306
CMD ["mysqld"]