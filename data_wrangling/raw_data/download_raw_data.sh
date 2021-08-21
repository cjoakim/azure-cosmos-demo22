#!/bin/bash

env | grep KAGGLE 

# https://www.kaggle.com/census/us-population-by-zip-code
# https://www.kaggle.com/PromptCloudHQ/all-jc-penny-products

rm -rf us-population-by-zip-code
rm -rf all-jc-penny-products

mkdir -p us-population-by-zip-code
mkdir -p all-jc-penny-products

cd ..
cd us-population-by-zip-code
kaggle datasets download -d census/us-population-by-zip-code
unzip us-population-by-zip-code.zip
rm *.zip

cd ..
cd all-jc-penny-products
kaggle datasets download -d PromptCloudHQ/all-jc-penny-products
unzip all-jc-penny-products.zip
rm *.zip

find *

echo 'done'
