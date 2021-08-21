#!/bin/bash

source ./config.sh

c=$container1

echo '---'
echo 'bulk loading container: '$c
$DOTNET_PGM run bulk_load_container $dbname $c route $air_travel_departures_file $load_max_count > tmp/load_$c.txt
