#!/bin/bash

# Provision an Ubuntu Virtual Machine (UVM) with the az CLI.
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

arg_count=$#
processed=0

create() {
    processed=1

    echo 'creating UVM rg: '$uvm_rg
    az group create \
        --location $uvm_region \
        --name $uvm_rg \
        --subscription $subscription \
        > tmp/uvm_rg_create.json

    echo 'creating UVM: '$uvm_name
    az vm create \
        --name $uvm_name \
        --resource-group $uvm_rg \
        --subscription $subscription \
        --location $uvm_region \
        --image $uvm_image \
        --size $uvm_size \
        --admin-username $uvm_user \
        --authentication-type ssh \
        --ssh-key-values $uvm_ssh_keys \
        --verbose \
        --output json \
        > tmp/uvm_vm_create.json
}

info() {
    processed=1
    echo 'az vm list ...'
    az vm list > tmp/vm_list.json

    echo 'az vm show ...'
    az vm show \
        --name $uvm_name \
        --resource-group $uvm_rg \
        > tmp/vm_show.json
}

uvm_metadata() {
    processed=1
    uvm_skus
    uvm_sizes
    uvm_usage
}

uvm_skus() {
    processed=1
    az vm list-skus --location $uvm_region > tmp/uvm_list_skus.json
}

uvm_sizes() {
    processed=1
    az vm list-sizes --location $uvm_region > tmp/uvm_list_sizes.json
}

uvm_usage() {
    processed=1
    az vm list-usage --location $uvm_region > tmp/uvm_list_usage.json
}

display_usage() {
    echo 'Usage:'
    echo './uvm.sh create'
    echo './uvm.sh info'
    echo './uvm.sh uvm_skus'
    echo './uvm.sh uvm_sizes'
    echo './uvm.sh uvm_usage'
    echo './uvm.sh uvm_metadata'
}

# ========== "main" logic below ==========

if [[ $arg_count -gt 0 ]];
then
    for arg in $@
    do
        if [[ $arg == "create" ]];       then create; fi 
        if [[ $arg == "info" ]];         then info; fi 
        if [[ $arg == "uvm_skus" ]];     then uvm_skus; fi 
        if [[ $arg == "uvm_sizes" ]];    then uvm_sizes; fi 
        if [[ $arg == "uvm_usage" ]];    then uvm_usage; fi 
        if [[ $arg == "uvm_metadata" ]]; then uvm_metadata; fi 
    done
fi

if [[ $processed -eq 0 ]]; then display_usage; fi

echo 'done'
