#!/bin/bash

source ./config.sh

echo '---'
echo 'delete database: '$dbname
dotnet run delete_database $dbname

echo '---'
echo 'sleeping after delete database: '$sleep_seconds
sleep sleep_seconds

echo '---'
echo 'create database: '$dbname
dotnet run create_database $dbname $shared_ru

echo '---'
echo 'create container: '$container1
dotnet run create_container $dbname $container1 $pk1 0

echo '---'
echo 'create container: '$container2
dotnet run create_container $dbname $container2 $pk1 0

echo '---'
echo 'create container: '$container3
dotnet run create_container $dbname $container3 $pk1 0

echo '---'
echo 'create container: '$container4
dotnet run create_container $dbname $container4 $pk2 0


echo '---'
echo 'list databases:'
dotnet run list_databases

echo '---'
echo 'list containers in database: '$dbname
dotnet run list_containers $dbname

echo 'changing to az directory...'
cd ../../../az
pwd

echo '---'

echo 'updating indexing policy for container: '$container1
./cosmos_index_update.sh $dbname $container1 default.json

echo 'updating indexing policy for container: '$container2
./cosmos_index_update.sh $dbname $container2 none.json

echo 'updating indexing policy for container: '$container3
./cosmos_index_update.sh $dbname $container3 optimized.json

echo 'updating indexing policy for container: '$container3
./cosmos_index_update.sh $dbname $container4 default.json

echo 'changing back to CosmosConsole22 directory...'
cd ../dotnet/Cosmos22/CosmosConsole22/
pwd

echo 'done'
