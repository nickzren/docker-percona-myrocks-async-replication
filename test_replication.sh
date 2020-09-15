#!/bin/bash

ehco "creating database (master_db)"
docker exec master_db mysql -uroot -proot -e "create database test_db;"

echo "creating table (master_db)"
docker exec master_db mysql -uroot -proot -e "use test_db; CREATE TABLE test_table (id int NOT NULL, num1 int NOT NULL, num2 float NOT NULL, str varchar(5) NOT NULL, PRIMARY KEY (id)) ENGINE=ROCKSDB PARTITION BY Key(id) PARTITIONS 3;"

echo "load data (master_db)"
docker exec master_db mysql -uroot -proot -e "use test_db; load data infile '/var/lib/mysql-files/test_data.tsv' into table test_table"

echo "check count, it should be 100000 (replica_db)"
docker exec master_db mysql -uroot -proot -e "use test_db; select count(*) from test_table"



# mysql -h127.0.0.1 -uroot -proot -P3308
# mysql -h127.0.0.1 -uroot -proot -P3309