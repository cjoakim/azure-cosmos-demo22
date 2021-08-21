#!/bin/bash

# Create a Service Principal (SP) with the az CLI.
# This SP can be used to "az login", without a browser, on an Azure VM.
# Chris Joakim, Microsoft, August 2021

spname="CosmosDBDemo22"

echo 'creating a Service Principal named: '$spname
#az ad sp create-for-rbac --name $spname

echo ''
echo 'Capture these generated values as environment variables:'
echo 'export AZURE_DEMO22_SP_APP_ID="...above appId..."'
echo 'export AZURE_DEMO22_SP_DISPLAY_NAME="...above displayName..."'
echo 'export AZURE_DEMO22_SP_NAME="...above name..."'
echo 'export AZURE_DEMO22_SP_PASSWORD="...above password..."'
echo 'export AZURE_DEMO22_SP_TENANT="...above tenant..."'
echo ''
