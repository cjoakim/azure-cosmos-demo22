#!/bin/bash

# Update a given CosmosDB database and container with the given
# indexing policy filename.  These three args are required.
# Chris Joakim, Microsoft, August 2021

source ./config.sh

mkdir -p tmp/

# | c1         | Default   | route     | az/indexing_policies/default.json   |
# | c2         | None      | route     | az/indexing_policies/none.json      |
# | c3         | Optimized | route     | az/indexing_policies/optimized.json |
# | c4         | Default   | from_iata | az/indexing_policies/default.json   |

display_usage() {
    echo 'Usage:'
    echo './cosmos_index_update.sh <db> <container> <policy.json>'
    echo './cosmos_index_update.sh demo22 c1 default.json'
    echo './cosmos_index_update.sh demo22 c2 none.json'
    echo './cosmos_index_update.sh demo22 c3 optimized.json'
    echo './cosmos_index_update.sh demo22 c4 default.json'
}

arg_count=$#

if [[ $arg_count -gt 2 ]];
then
    echo 'database:  '$1
    echo 'container: '$2
    echo 'json file: '$3

    echo 'az cosmosdb sql container update ...'
    az cosmosdb sql container update \
        --resource-group $cosmos_sql_rg \
        --account-name $cosmos_sql_acct_name \
        --database-name $1 \
        --analytical-storage-ttl -1 \
        --name $2 \
        --idx @indexing_policies/$3 \
        > tmp/cosmos_index_update_$2.json
else
    display_usage
fi

echo 'done'
