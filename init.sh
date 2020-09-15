#!/bin/bash

docker-compose down

rm -rf data/master
mkdir data/master
rm -rf data/replica
mkdir data/replica

docker-compose up -d

while ! docker exec master_db mysql --user=root --password=root -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for master database connection..."
    sleep 5
done

while ! docker exec replica_db mysql --user=root --password=root -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for replica database connection..."
    sleep 5
done

echo "creating replica user"
REPLICATION_USER="replica"
REPLICATION_PASSWORD="replica"
docker exec master_db mysql -uroot -proot -e "CREATE USER '$REPLICATION_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$REPLICATION_PASSWORD';"
docker exec master_db mysql -uroot -proot -e "GRANT REPLICATION SLAVE ON *.* TO '$REPLICATION_USER'@'%';"

echo "getting MASTER File and Position"
Master_File="$(docker exec master_db mysql -uroot -proot -e 'show master status \G' | grep File | sed -n -e 's/^.*: //p')"
Master_Position="$(docker exec master_db mysql -uroot -proot -e 'show master status \G' | grep Position | grep -Eo '[0-9]{1,}')"

echo "reset rocksdb_max_row_locks"
docker exec master_db mysql -uroot -proot -e "set global rocksdb_max_row_locks = 1073741824"
docker exec replica_db mysql -uroot -proot -e "set global rocksdb_max_row_locks = 1073741824"

echo "init replica server for connecting to the master server"
docker exec replica_db mysql -uroot -proot -e "CHANGE MASTER TO MASTER_HOST='master_db',MASTER_USER='$REPLICATION_USER', MASTER_PASSWORD='$REPLICATION_PASSWORD', MASTER_LOG_FILE='$Master_File', MASTER_LOG_POS=$Master_Position;"
#docker exec replica_db mysql -uroot -proot -e "show slave status \G"
docker exec replica_db mysql -uroot -proot -e "start slave";

echo "master replication services started"