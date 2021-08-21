#!/bin/bash

# Provision Azure Synapse Workspace, and related services, with the az CLI.
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

arg_count=$#
processed=0

delete() {
    processed=1
    echo 'deleting synapse rg: '$synapse_rg
    az group delete \
        --name $synapse_rg \
        --subscription $subscription \
        --yes \
        > _rg_delete.json
}

create() {
    processed=1
    az extension add --name synapse

    echo 'creating synapse rg: '$synapse_rg
    az group create \
        --location $synapse_region \
        --name $synapse_rg \
        --subscription $subscription \
        > tmp/synapse_rg_create.json

    echo 'creating synapse storage (ADL V2) acct: '$synapse_name
    az storage account create \
        --name $synapse_name \
        --resource-group $synapse_rg \
        --location $synapse_region \
        --sku $synapse_stor_sku \
        --kind StorageV2 \
        --hierarchical-namespace true \
        > tmp/synapse_storage_acct_create.json

    pause

    storage_name=$synapse_name

    echo 'creating synapse workspace: '$synapse_name' with storage: '$storage_name
    az synapse workspace create \
        --name $synapse_name \
        --resource-group $synapse_rg \
        --storage-account $storage_name \
        --file-system $synapse_fs_name \
        --sql-admin-login-user $synapse_admin_user \
        --sql-admin-login-password $synapse_admin_pass \
        --location $synapse_region \
        > tmp/synapse_workspace_create.json

    pause

    echo 'creating synapse workspace firewall-rule'
    az synapse workspace firewall-rule create \
        --name allowAll \
        --workspace-name $synapse_name \
        --resource-group $synapse_rg \
        --start-ip-address 0.0.0.0 \
        --end-ip-address 255.255.255.255  \
        > tmp/synapse_firewall_rule_create.json
}

create_spark_pool() {
    processed=1
    echo 'az synapse spark pool create: '$synapse_spark_pool_name
    az synapse spark pool create \
        --name $synapse_spark_pool_name \
        --workspace-name $synapse_name \
        --resource-group $synapse_rg \
        --spark-version 2.4 \
        --enable-auto-pause true \
        --delay 120 \
        --node-count $synapse_spark_pool_count \
        --node-size $synapse_spark_pool_size \
        > tmp/synapse_spark_pool_create.json
}

recreate() {
    processed=1
    rm tmp/synapse/*.*
    delete
    create
    info 
}

info() {
    processed=1
    echo 'az storage acct show: '$synapse_name
    az storage account show \
        --name $synapse_name \
        --resource-group $synapse_rg \
        --subscription $subscription \
        > tmp/synapse_storage_acct_show.json

    echo 'az storage acct keys: '$synapse_name
    az storage account keys list \
        --account-name $synapse_name \
        --resource-group $synapse_rg \
        --subscription $subscription \
        > tmp/synapse_storage_acct_keys.json

    echo 'az synapse workspace list:'
    az synapse workspace list \
        > tmp/synapse_workspace_list.json

    echo 'synapse acct show: '$synapse_name
    az synapse workspace show \
        --name $synapse_name \
        --resource-group $synapse_rg \
        > tmp/synapse_acct_show.json

    echo 'az synapse spark pool list: '$synapse_name
    az synapse spark pool list \
        --resource-group $synapse_rg \
        --workspace-name $synapse_name \
        > tmp/synapse_spark_pool_list.json

    echo 'az synapse spark pool show: '$synapse_spark_pool_name
    az synapse spark pool show \
        --name $synapse_spark_pool_name \
        --resource-group $synapse_rg \
        --workspace-name $synapse_name \
        > tmp/synapse_spark_pool_show.json
}

pause() {
    echo 'pause/sleep 60...'
    sleep 60
}

display_usage() {
    echo 'Usage:'
    echo './synapse.sh delete'
    echo './synapse.sh create'
    echo './synapse.sh create_spark_pool'
    echo './synapse.sh recreate'
    echo './synapse.sh info'
    echo './synapse.sh create pause create_spark_pool pause info'
    echo './synapse.sh recreate pause create_spark_pool pause info'
}

# ========== "main" logic below ==========

date 

if [[ $arg_count -gt 0 ]];
then
    for arg in $@
    do
        if [[ $arg == "delete" ]];            then delete; fi 
        if [[ $arg == "create" ]];            then create; fi 
        if [[ $arg == "create_spark_pool" ]]; then create_spark_pool; fi 
        if [[ $arg == "recreate" ]];          then recreate; fi 
        if [[ $arg == "info" ]];              then info; fi 
        if [[ $arg == "pause" ]];             then pause; fi 
    done
fi

if [[ $processed -eq 0 ]]; then display_usage; fi

date 
echo 'done'
