#!/bin/bash

source ./config.sh

c=$container4

echo '---'
echo 'bulk loading container: '$c
$DOTNET_PGM run bulk_load_container $dbname $c from_iata $air_travel_departures_file $load_max_count > tmp/load_$c.txt
