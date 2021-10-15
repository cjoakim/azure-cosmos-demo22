
"""
Usage:
    python main.py wrangle_departures
    python main.py wrangle_departures_csv_to_json > data/air_travel_departures.json
    python main.py gen_departure_class
    python main.py join_zipcode_data
    python main.py create_query_results_table | sort
"""

__author__  = 'Chris Joakim'
__email__   = "chjoakim@microsoft.com"
__license__ = "MIT"
__version__ = "August 2021"


import csv
import json
import os
import random
import sys
import time
import traceback
import uuid

import numpy as np
import pandas as pd

from decimal import *
from docopt import docopt
from faker import Faker

world_airports_dict = dict()


def wrangle_departures():
    infile  = 'raw_data/kaggle-us-international-air-traffic/International_Report_Departures.csv'
    outfile = 'data/air_travel_departures.csv'

    world_airports_list = load_json_file('data/world_airports.json')
    for a in world_airports_list:
        pk = a['pk']
        world_airports_dict[pk] = a

    df = pd.read_csv(infile, delimiter=",")
    describe_df(df, 'raw df')

    df['route'] = df.apply(lambda row: market_column(row), axis=1)
    df['data_dte'] = df.apply(lambda row: reformat_departure_date(row), axis=1)

    df['from_airport_name'] = df.apply(lambda row: from_airport_name(row), axis=1)
    df['from_airport_tz']   = df.apply(lambda row: from_airport_tz(row), axis=1)
    df['from_airport_lat']  = df.apply(lambda row: from_airport_lat(row), axis=1)
    df['from_airport_lng']  = df.apply(lambda row: from_airport_lng(row), axis=1)

    df['to_airport_name'] = df.apply(lambda row: to_airport_name(row), axis=1)
    df['to_airport_country'] = df.apply(lambda row: to_airport_country(row), axis=1)
    df['to_airport_tz']   = df.apply(lambda row: to_airport_tz(row), axis=1)
    df['to_airport_lat']  = df.apply(lambda row: to_airport_lat(row), axis=1)
    df['to_airport_lng']  = df.apply(lambda row: to_airport_lng(row), axis=1)

    drop_cols = 'usg_apt_id,usg_wac,fg_apt_id,fg_wac,type,carriergroup,Scheduled,Charter'.split(',')
    df2 = df.drop(drop_cols, axis=1).drop_duplicates()
    describe_df(df2, 'dropped cols')

    df3 = df2.rename(columns={
        "data_dte": "date", 
        "Year": "year", 
        "Month": "month",
        "usg_apt": "from_iata", 
        "fg_apt": "to_iata", 
        "Total": "count"})
    describe_df(df3, 'transformed')

    df3.to_csv(outfile, index=False, sep='|')

def market_column(row):
    iata1 = row['usg_apt']
    iata2 = row['fg_apt']
    return '{}:{}'.format(iata1, iata2).upper()

def reformat_departure_date(row):
    tokens = row['data_dte'].split('/')  # 05/01/2006
    if len(tokens) == 3:
        return '{}/{}/{}'.format(tokens[2], tokens[0], tokens[1])
    else:
        return 'NA'

def from_airport_name(row):
    try:
        iata = row['usg_apt']
        return world_airports_dict[iata]['name']
    except:
        return 'NA'

def from_airport_tz(row):
    try:
        iata = row['usg_apt']
        return world_airports_dict[iata]['timezone_code']
    except:
        return 'NA'

def from_airport_lat(row):
    try:
        iata = row['usg_apt']
        return world_airports_dict[iata]['location']['coordinates'][1]
    except:
        return '-0'

def from_airport_lng(row):
    try:
        iata = row['usg_apt']
        return world_airports_dict[iata]['location']['coordinates'][0]
    except:
        return '-0'

def to_airport_name(row):
    try:
        iata = row['fg_apt']
        return world_airports_dict[iata]['name']
    except:
        return 'NA'

def to_airport_country(row):
    try:
        iata = row['fg_apt']
        return world_airports_dict[iata]['country']
    except:
        return 'NA'

def to_airport_tz(row):
    try:
        iata = row['fg_apt']
        return world_airports_dict[iata]['timezone_code']
    except:
        return 'NA'

def to_airport_lat(row):
    try:
        iata = row['fg_apt']
        return world_airports_dict[iata]['location']['coordinates'][1]
    except:
        return '-0'

def to_airport_lng(row):
    try:
        iata = row['fg_apt']
        return world_airports_dict[iata]['location']['coordinates'][0]
    except:
        return '-0'

def gen_departure_class():
    lines = read_lines('data/departure.txt') 
    for line in lines:
        attr_name = line.split()[0]
        print('        public string {} < get; set; >'.format(attr_name).replace('<','{').replace('>','}'))
        print('')

def wrangle_departures_csv_to_json():
    infile = 'data/air_travel_departures.csv'
    it = text_file_iterator(infile)
    headers = list()
    for i, line in enumerate(it):
        tokens = line.strip().split('|')
        if i == 0:
            headers = tokens
            # for col_idx, col in enumerate(headers):
            #     print("            data['{}'] = tokens[{}]".format(col, col_idx))
        else:
            data = dict()
            data['id'] = str(uuid.uuid1())
            data['pk'] = tokens[8]
            data['date'] = tokens[0]
            data['year'] = tokens[1]
            data['month'] = tokens[2]
            data['from_iata'] = tokens[3]
            data['to_iata'] = tokens[4]
            data['airlineid'] = tokens[5]
            data['carrier'] = tokens[6]
            data['count'] = tokens[7]
            data['route'] = tokens[8]
            data['from_airport_name'] = tokens[9]
            data['from_airport_tz'] = tokens[10]
            # data['from_airport_lat'] = tokens[11]
            # data['from_airport_lng'] = tokens[12]
            data['from_location'] = location(tokens[11], tokens[12])
            data['to_airport_name'] = tokens[13]
            data['to_airport_country'] = tokens[14]
            data['to_airport_tz'] = tokens[15]
            # data['to_airport_lat'] = tokens[16]
            # data['to_airport_lng'] = tokens[17]
            data['to_location'] = location(tokens[16], tokens[17])
            data['doc_epoch'] = time.time()
            jstr = json.dumps(data)
            print(jstr)

def location(lat, lng):
    loc = dict()
    loc['type'] = 'Point'
    loc['coordinates'] = [ -0.0, -0.0]
    try:
        loc['coordinates'][0] = float(lng)
        loc['coordinates'][1] = float(lat)
    except:
        pass
    return loc

def explore_kaggle_data():
    infile = 'raw_data/kaggle-us-international-air-traffic/International_Report_Departures.csv'
    it = text_file_iterator(infile)
    headers = list()

    for i, line in enumerate(it):
        tokens = line.strip().split(',')
        if i == 0:
            headers = tokens
        else:
            if 'CLT' in line:
                if 'MBJ' in line:
                    print('---')
                    print(line)
                    for field_idx, field in enumerate(headers):
                        field_val = tokens[field_idx]
                        print('{:<3} {:<16}  {}'.format(field_idx, field, field_val))

# data_dte,Year,Month,usg_apt_id,usg_apt,usg_wac,fg_apt_id,fg_apt,fg_wac,airlineid,carrier,carriergroup,type,Scheduled,Charter,Total
# 05/01/2006,2006,5,12016,GUM,5,13162,MAJ,844,20177,PFQ,1,Departures,0,10,10

def create_query_results_table():
    infile = '../dotnet/Cosmos22/CosmosConsole22/out/execute_queries.txt'
    lines, responses = read_lines(infile), list()
    for line in lines:
        if line.strip().startswith('QueryResponse'):
            qr = QueryResponse(line.strip())
            responses.append(qr)
    for qr in responses:
        print(qr)

def load_json_file(infile):
    with open(infile) as json_file:
        return json.load(json_file)

def read_csv_file(csv_file, greater_than_index=0):
    lines = list()
    it = text_file_iterator(csv_file)
    for i, line in enumerate(it):
        if i > greater_than_index:
            lines.append(line.strip())
    return lines

def read_lines(infile):
    lines = list()
    with open(infile, 'rt') as f:
        for line in f:
            lines.append(line)
    return lines

def text_file_iterator(infile):
    with open(infile, 'rt') as f:
        for line in f:
            yield line.strip()

def describe_df(df, msg):
    print('=== describe df: {}'.format(msg))
    print('--- df.dtypes')
    print(df.dtypes)
    print('--- df.shape')
    print(df.shape)

def print_options(msg):
    print(msg)
    arguments = docopt(__doc__, version=__version__)
    print(arguments)


class QueryResponse(object):

    def __init__(self, line):
        # ['QueryResponse:', 'q2', 'demo22', 'c3', 'OK', '17.38', '16', '52.6803', 'False']
        tokens = line.split()
        self.line   = line
        self.name   = tokens[1]
        self.dbname = tokens[2]
        self.cname  = tokens[3]
        self.status = tokens[4]
        self.ru     = float(tokens[5])
        self.items  = int(tokens[6])
        self.ms     = float(tokens[7])
        self.excp   = tokens[8]
        print(tokens)

    def __str__(self):
        r = '{:.3f}'.format(self.ru)
        m = '{:.4f}'.format(self.ms)

        return '| {:<5} | {:>6} | {:>3} | {:>8} | {:<5} | {} |'.format(
            self.name, self.dbname, self.cname, r,
            str(self.items), self.status)


if __name__ == "__main__":

    if len(sys.argv) > 1:
        func = sys.argv[1].lower()

        if func == 'wrangle_departures':
            wrangle_departures()

        elif func == 'wrangle_departures_csv_to_json':
            wrangle_departures_csv_to_json()

        elif func == 'gen_departure_class':
            gen_departure_class()

        elif func == 'explore_kaggle_data':
            explore_kaggle_data()

        elif func == 'create_query_results_table':
            create_query_results_table()
        else:
            print_options('Error: invalid command-line function: {}'.format(func))
    else:
        print_options('Error: no command-line function given')
