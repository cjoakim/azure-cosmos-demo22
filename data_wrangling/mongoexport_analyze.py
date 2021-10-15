
"""
Usage:
    python mongoexport_analyze.py hello_matplotlib
    python mongoexport_analyze.py pk_analysis raw_data/mongoexport/openflights__routes.json
"""

__author__  = 'Chris Joakim'
__email__   = "chjoakim@microsoft.com"
__license__ = "MIT"
__version__ = "October 2021"

# Links:
# https://pandas.pydata.org/
# https://matplotlib.org/
# https://pandas.pydata.org/docs/getting_started/intro_tutorials/04_plotting.html

import os
import sys
import time
import traceback

import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt

from docopt import docopt

plt.style.use('classic')

def hello_matplotlib():
    # simple test of your python configuration.  if you run 
    # 'python mongoexport_analyze.py hello_matplotlib' on the command-line
    # and see a popup window with a graph, then it's working properly.
    x = np.linspace(0, 10, 100)
    plt.plot(x, np.sin(x))
    plt.plot(x, np.cos(x))
    plt.show()

def pk_analysis(infile):
    print('mongoexport_pk_analyze: {}'.format(infile))
    df = pd.read_json(infile, lines=True)
    describe_df(df, 'mongoexport file: {}'.format(infile))
    print(df.head())
    candidate_attrs = 'airline_id,from_airport,to_airport,equipment'.split(',')
    show_popup_visualization = False

    for attr_name in candidate_attrs:
        unique_values = df[attr_name].unique()
        print("attribute '{}' has {} unique values".format(attr_name, len(unique_values)))
        counts = df[attr_name].value_counts()
        counts.plot()
        if show_popup_visualization:
            plt.show()
        else:
            outfile = 'plots/{}.png'.format(attr_name)
            plt.savefig(outfile)
            print('plot saved to file {}'.format(outfile))

def describe_df(df, msg):
    print('=== describe df: {}'.format(msg))
    print(str(type(df)))  # <class 'pandas.core.frame.DataFrame'>
    print('--- df.dtypes')
    print(df.dtypes)
    print('--- df.shape')
    print(df.shape)

def print_options(msg):
    print(msg)
    arguments = docopt(__doc__, version=__version__)
    print(arguments)


if __name__ == "__main__":

    if len(sys.argv) > 1:
        func = sys.argv[1].lower()

        if func == 'hello_matplotlib':
            hello_matplotlib()
        elif func == 'pk_analysis':
            infile = sys.argv[2]
            pk_analysis(infile)
        else:
            print_options('Error: invalid command-line function: {}'.format(func))
    else:
        print_options('Error: no command-line function given')


# Sample Output:
#
# $ python mongoexport_analyze.py pk_analysis raw_data/mongoexport/openflights__routes.json
# mongoexport_pk_analyze: raw_data/mongoexport/openflights__routes.json
# === describe df: mongoexport file: raw_data/mongoexport/openflights__routes.json
# <class 'pandas.core.frame.DataFrame'>
# --- df.dtypes
# _id                         object
# airline_id                  object
# openflights_airline_id      object
# from_airport                object
# openflights_from_airport    object
# to_airport                  object
# openflights_to_airport      object
# x                           object
# codeshare                    int64
# equipment                   object
# dtype: object
# --- df.shape
# (67663, 10)
#                                     _id airline_id openflights_airline_id  ... x codeshare equipment
# 0  {'$oid': '6166d5927a8e7d4fa3497300'}         2B                    410  ...           0       CR2
# 1  {'$oid': '6166d5927a8e7d4fa3497301'}         2B                    410  ...           0       CR2
# 2  {'$oid': '6166d5927a8e7d4fa3497302'}         2B                    410  ...           0       CR2
# 3  {'$oid': '6166d5927a8e7d4fa3497303'}         2B                    410  ...           0       CR2
# 4  {'$oid': '6166d5927a8e7d4fa3497304'}         2B                    410  ...           0       CR2

# [5 rows x 10 columns]
# attribute 'airline_id' has 568 unique values
# plot saved to file plots/airline_id.png
# attribute 'from_airport' has 3409 unique values
# plot saved to file plots/from_airport.png
# attribute 'to_airport' has 3418 unique values
# plot saved to file plots/to_airport.png
# attribute 'equipment' has 3946 unique values
# plot saved to file plots/equipment.png
