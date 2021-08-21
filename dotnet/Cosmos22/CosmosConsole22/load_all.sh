#!/bin/bash

source ./config.sh

mkdir -p tmp
rm tmp/*.txt

echo 'executing load_cosmos_container1.sh ...'
./load_cosmos_container1.sh

echo 'executing load_cosmos_container2.sh ...'
./load_cosmos_container2.sh

echo 'executing load_cosmos_container3.sh ...'
./load_cosmos_container3.sh

echo 'executing load_cosmos_container4.sh ...'
./load_cosmos_container4.sh

echo 'loads completed'
