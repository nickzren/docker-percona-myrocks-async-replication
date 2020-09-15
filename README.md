Docker Percona MyRocks Async Replication
========================

RocksDB becomes a much more robust and feature complete storage engine, it requires less storage space and ensures better IO capacity. I have been used Percona Server for years, this docker setup instruction will be based on Percona Myrocks.

## Requirement

* docker-compose >= 3.0

## Run

#### Create master-replica container services

```
./init.sh
```

#### Create testing database, testing table; load testing data; check replication data

```
./test_replication.sh
```

## Check

#### Check Logs

```
docker-compose logs
```

#### Check Master/Replica status

```
docker exec -it master_db mysql -uroot -proot -e "SHOW MASTER STATUS \G"
docker exec -it replica_db mysql -uroot -proot -e "SHOW SLAVE STATUS \G"
```

#### Start a Master/Replica Bash session

```
docker exec -it master_db bash
docker exec -it replica_db bash
```

## Reference
* https://hub.docker.com/_/percona
* https://docs.docker.com/
* https://docs.docker.com/compose/
* https://www.percona.com/blog/2019/12/27/mysql-docker-containers-quick-async-replication-test-setup/
* https://www.percona.com/blog/2019/11/19/installing-mysql-with-docker/
* https://dev.to/sonyarianto/how-to-spin-mysql-server-with-docker-and-docker-compose
* https://github.com/vbabak/docker-mysql-master-slave/