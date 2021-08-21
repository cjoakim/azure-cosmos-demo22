#!/bin/bash

# Provision an Azure Cosmos/SQL DB account with the az CLI.
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

arg_count=$#
processed=0

delete() {
    processed=1
    echo 'deleting cosmos rg: '$cosmos_sql_rg
    az group delete \
        --name $cosmos_sql_rg \
        --subscription $subscription \
        --yes \
        > tmp/cosmos_sql_rg_delete.json
}

create() {
    processed=1
    echo 'creating cosmos rg: '$cosmos_sql_rg
    az group create \
        --location $cosmos_sql_region \
        --name $cosmos_sql_rg \
        --subscription $subscription \
        > tmp/cosmos_sql_rg_create.json

    echo 'creating cosmos acct: '$cosmos_sql_acct_name
    # https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_create
    az cosmosdb create \
        --name $cosmos_sql_acct_name \
        --resource-group $cosmos_sql_rg \
        --subscription $subscription \
        --locations regionName=$cosmos_sql_region failoverPriority=0 isZoneRedundant=False \
        --default-consistency-level $cosmos_sql_acct_consistency \
        --enable-multiple-write-locations true \
        --enable-analytical-storage true \
        --analytical-storage-schema-type FullFidelity \
        --kind $cosmos_sql_acct_kind \
        > tmp/cosmos_sql_acct_create.json

    create_db   
}

recreate_all() {
    processed=1
    delete
    create
    info 
}

recreate_db() {
    processed=1
    delete_db
    create_db  
    info   
}

delete_db() {
    processed=1
    echo 'deleting cosmos db: '$cosmos_sql_dbname
    az cosmosdb sql database delete \
        --resource-group $cosmos_sql_rg \
        --account-name $cosmos_sql_acct_name \
        --name $cosmos_sql_dbname \
        --yes -y \
        > tmp/cosmos_sql_db_delete.json
}

create_db() {
    processed=1
    echo 'creating cosmos db: '$cosmos_sql_dbname
    az cosmosdb sql database create \
        --resource-group $cosmos_sql_rg \
        --account-name $cosmos_sql_acct_name \
        --name $cosmos_sql_dbname \
        --max-throughput $cosmos_sql_db_throughput \
        > tmp/cosmos_sql_db_create.json
}

# create_collections() {
#     processed=1
#     echo 'creating cosmos collection: '$cosmos_sql_airports_collname
#     az cosmosdb sql container create \
#         --resource-group $cosmos_sql_rg \
#         --account-name $cosmos_sql_acct_name \
#         --database-name $cosmos_sql_dbname \
#         --name airports \
#         --subscription $subscription \
#         --partition-key-path /pk \
#         > tmp/cosmos_sql_db_create_airports.json

#     az cosmosdb sql container create \
#         --resource-group $cosmos_sql_rg \
#         --account-name $cosmos_sql_acct_name \
#         --database-name $cosmos_sql_dbname \
#         --name amtrak \
#         --subscription $subscription \
#         --partition-key-path /pk \
#         > tmp/cosmos_sql_db_create_amtrak.json
# }

info() {
    processed=1
    echo 'az cosmosdb show ...'
    az cosmosdb show \
        --name $cosmos_sql_acct_name \
        --resource-group $cosmos_sql_rg \
        > tmp/cosmos_sql_db_show.json

    echo 'az cosmosdb keys list - keys ...'
    az cosmosdb keys list \
        --resource-group $cosmos_sql_rg \
        --name $cosmos_sql_acct_name \
        --type keys \
        > tmp/cosmos_sql_db_keys.json

    echo 'az cosmosdb keys list - read-only-keys ...'
    az cosmosdb keys list \
        --resource-group $cosmos_sql_rg \
        --name $cosmos_sql_acct_name \
        --type read-only-keys \
        > tmp/cosmos_sql_db_read_only_keys.json

    echo 'az cosmosdb keys list - connection-strings ...'
    az cosmosdb keys list \
        --resource-group $cosmos_sql_rg \
        --name $cosmos_sql_acct_name \
        --type connection-strings \
        > tmp/cosmos_sql_db_connection_strings.json

    # This command has been deprecated and will be removed in a future release. Use 'cosmosdb keys list' instead.
}

display_usage() {
    echo 'Usage:'
    echo './cosmos_sql.sh delete'
    echo './cosmos_sql.sh create'
    echo './cosmos_sql.sh recreate'
    echo './cosmos_sql.sh recreate_db'
    echo './cosmos_sql.sh info'
}

# ========== "main" logic below ==========

if [[ $arg_count -gt 0 ]];
then
    for arg in $@
    do
        if [[ $arg == "delete" ]];   then delete; fi 
        if [[ $arg == "create" ]];   then create; fi 
        if [[ $arg == "recreate" ]]; then recreate_all; fi 
        if [[ $arg == "recreate_db" ]]; then recreate_db; fi 
        if [[ $arg == "info" ]];     then info; fi 
    done
fi

if [[ $processed -eq 0 ]]; then display_usage; fi

echo 'done'
