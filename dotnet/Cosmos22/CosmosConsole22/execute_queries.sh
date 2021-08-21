#!/bin/bash

source ./config.sh

rm out/q*.json

dotnet run execute_queries demo22 c1 sql/queries.txt
dotnet run execute_queries demo22 c2 sql/queries.txt
dotnet run execute_queries demo22 c3 sql/queries.txt
dotnet run execute_queries demo22 c4 sql/queries.txt

echo 'queries completed'
