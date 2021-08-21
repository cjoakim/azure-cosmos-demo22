#!/bin/bash

# Chris Joakim, Microsoft, August 2021

# rm data/jcpenney*.csv
# rm data/us_population_by_zipcode*.csv
# rm data/postal_codes_us_with_population.csv

echo '---'
python main.py wrangle_retail_items
echo 'head data/jcpenney_skus.csv:'
head data/jcpenney_skus.csv

echo '---'
python main.py wrangle_us_population_by_zipcode
echo 'ungrouped 28036:'
cat  data/us_population_by_zipcode_ungrouped.csv | grep 28036
echo 'grouped 28036:'
cat  data/us_population_by_zipcode.csv | grep 28036
echo 'head data/us_population_by_zipcode.csv:'
head data/us_population_by_zipcode.csv
rm   data/us_population_by_zipcode_ungrouped.csv

echo '---'
python main.py join_zipcode_data
head data/postal_codes_us_with_population.csv
cat  data/postal_codes_us_with_population.csv | grep [,]28036[,]

echo '---'
python main.py generate_retail_sales_data 1000000 > data/retail_sales.json
wc  data/retail_sales.json
cat data/retail_sales.json | grep nm0000102
# note: retail_sales.json is in the .gitignore as it is too big; 737MB

echo '---'
ls -al data/ | grep csv

echo 'done'
