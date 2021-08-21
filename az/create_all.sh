#!/bin/bash

source ./config.sh

mkdir -p tmp/

echo 'az logout'
az logout

echo 'login without a sp ...'
az login 

./cosmos_sql.sh create

./la_wsp.sh create

./synapse.sh create pause create_spark_pool pause info
