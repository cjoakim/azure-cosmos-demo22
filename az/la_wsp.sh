#!/bin/bash

# Provision an Azure Log Analytics Workspace with the az CLI.
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

arg_count=$#
processed=0

delete() {
    processed=1
    echo 'deleting log analytics rg: '$la_wsp_rg
    az group delete \
        --name $la_wsp_rg \
        --subscription $subscription \
        --yes \
        > tmp/la_wsp_rg_delete.json
}

create() {
    processed=1
    echo 'creating log analytics rg: '$la_wsp_rg
    az group create \
        --location $la_wsp_region \
        --name $la_wsp_rg \
        --subscription $subscription \
        > tmp/la_wsp_rg_create.json

    echo 'creating log analytics workspace: '$la_wsp_name
    az monitor log-analytics workspace create \
        --location $la_wsp_region \
        --workspace-name $la_wsp_name \
        --resource-group $la_wsp_rg \
        --subscription $subscription \
        > tmp/la_wsp_rg_create.json
}

recreate() {
    processed=1
    delete
    create
    info 
}

info() {
    processed=1
    echo 'log analytics show: '$la_wsp_name
    az monitor log-analytics workspace show \
        --workspace-name $la_wsp_name \
        --resource-group $la_wsp_rg \
        --subscription $subscription \
        > tmp/la_wsp_show.json
}

display_usage() {
    echo 'Usage:'
    echo './la_wsp.sh delete'
    echo './la_wsp.sh create'
    echo './la_wsp.sh recreate'
    echo './la_wsp.sh info'
}

# ========== "main" logic below ==========

if [[ $arg_count -gt 0 ]];
then
    for arg in $@
    do
        if [[ $arg == "delete" ]];   then delete; fi 
        if [[ $arg == "create" ]];   then create; fi 
        if [[ $arg == "recreate" ]]; then recreate; fi 
        if [[ $arg == "info" ]];     then info; fi 
    done
fi

if [[ $processed -eq 0 ]]; then display_usage; fi

echo 'done'
