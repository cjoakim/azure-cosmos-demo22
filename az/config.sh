#!/bin/bash

# Bash shell that defines provisioning parameters and environment variables
# and is "sourced" by the other scripts in this directory.
#
# Some of these values from environment variables already defined on my
# system, such as USER, AZURE_SUBSCRIPTION_ID, AZURE_SYNAPSE_PASS,
# AZURE_UVM_USER and AZURE_UVM_PUBLIC_SSH_KEY.  You should likewise set these
# in your environment before running this script.
#
# NOTE: Please do a change-all on this script to change "cjoakim" to your ID.
#
# Chris Joakim, Microsoft, August 2021

export subscription=$AZURE_SUBSCRIPTION_ID
export user=$USER
export primary_region="eastus"
export primary_rg="cjoakimcosmosdemo22"
#
export adf_region=$primary_region
export adf_rg=$primary_rg
export adf_name="cjoakimadf22"
#
export cosmos_sql_region=$primary_region
export cosmos_sql_rg=$primary_rg
export cosmos_sql_acct_name="cjoakimcosmossql22"
export cosmos_sql_acct_consistency="Session"    # {BoundedStaleness, ConsistentPrefix, Eventual, Session, Strong}
export cosmos_sql_acct_kind="GlobalDocumentDB"  # {GlobalDocumentDB, MongoDB, Parse}
export cosmos_sql_dbname="demo"
export cosmos_sql_db_throughput="10000"
#
export la_wsp_region=$primary_region
export la_wsp_rg=$primary_rg
export la_wsp_name="cjoakimloganalytics22"
#
export storage_region=$primary_region
export storage_rg=$primary_rg
export storage_name="cjoakimstorage22"
export storage_kind="BlobStorage"     # {BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2}]
export storage_sku="Standard_LRS"     # {Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, , Standard_RAGRS, Standard_RAGZRS, Standard_ZRS]
export storage_access_tier="Hot"      # Cool, Hot
#
export synapse_region=$primary_region
export synapse_rg=$primary_rg
export synapse_name="cjoakimsynapse22"
export synapse_stor_kind="StorageV2"       # {BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2}]
export synapse_stor_sku="Standard_LRS"     # {Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, , Standard_RAGRS, Standard_RAGZRS, Standard_ZRS]
export synapse_stor_access_tier="Hot"      # Cool, Hot
export synapse_admin_user="cjoakim"
export synapse_admin_pass=$AZURE_SYNAPSE_PASS
export synapse_fs_name="synapse_acct"
export synapse_spark_pool_name="poolspark3s"
export synapse_spark_pool_count="3"
export synapse_spark_pool_size="Small"

export uvm_region=$primary_region
export uvm_rg=$primary_rg
export uvm_name="cjoakimvm22"
export uvm_publisher='Canonical'
# export uvm_offer='UbuntuServer'
# export uvm_sku='20.04-LTS'
# export uvm_version='latest'
#export uvm_image=""$uvm_publisher":"$uvm_offer":"$uvm_sku":"$uvm_version # Values from: az vm image list
export uvm_image='UbuntuLTS'
export uvm_size="Standard_D3_v2"               # Values from: az vm list-sizes, Default: Standard_DS1_v2
export uvm_datasizegb="1024"
export uvm_user=$AZURE_UVM_USER                # cjoakim
export uvm_ssh_keys=$AZURE_UVM_PUBLIC_SSH_KEY  # $HOME/<user>/.ssh/<name>.pub
