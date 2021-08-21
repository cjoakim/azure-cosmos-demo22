#!/bin/bash

# Bash script with AZ CLI to automate the creation of an
# Azure Data Factory account.
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

arg_count=$#
processed=0

mkdir -p tmp

create() {
    processed=1
    echo 'creating adf rg: '$adf_rg
    az group create \
        --location $adf_region \
        --name $adf_rg \
        --subscription $subscription \
        > tmp/adf_rg_create.json

    echo 'creating adf acct: '$adf_name
    az datafactory factory create \
        --location $adf_region \
        --name $adf_name \
        --resource-group $adf_rg \
        > tmp/adf1_acct_create.json
}

display_usage() {
    echo 'Usage:'
    echo './adf1.sh create'
}

# ========== "main" logic below ==========

if [ $arg_count -gt 0 ]
then
    for arg in $@
    do
        if [ $arg == "create" ]; then create; fi 
    done
fi

if [ $processed -eq 0 ]; then display_usage; fi

echo 'done'
