#!/bin/bash

# Environment variables used by the shell scripts in this directory:
export dbname="demo22"
export shared_ru="60000"
export container1="c1"
export container2="c2"
export container3="c3"
export container4="c4"

export pk1="/pk"
export pk2="/from_iata"

export sleep_seconds="10"

export air_travel_departures_file="data_wrangling/data/air_travel_departures.json"

export load_max_count="999999999"

# Environment variables used by the C# code in this directory
export AZURE_COSMOSDB_DEMO22_BULK_BATCH_SIZE="100"

if [[ $HOME == "/home/cjoakim" ]];
then
    #echo 'were on linux' 
    export DOTNET_PGM="/usr/local/bin/dotnet"  # odd snap issue on VM
else
    #echo 'were on macOS' 
    export DOTNET_PGM="dotnet"
fi 
