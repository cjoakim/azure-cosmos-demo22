#!/bin/bash

# Execute this script first to setup your az installation.
# See https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

echo 'adding az extensions ...'
az extension add -n storage-preview
az extension add --name synapse

echo 'az login in with service principal ...'
az login --service-principal \
    --username $AZURE_DEMO22_SP_APP_ID \
    --password $AZURE_DEMO22_SP_PASSWORD \
    --tenant   $AZURE_DEMO22_SP_TENANT

echo 'setting subscription ...'
az account set --subscription $AZURE_SUBSCRIPTION_ID

echo 'account show ...'
az account show >  tmp/account_show.json

echo 'done'
