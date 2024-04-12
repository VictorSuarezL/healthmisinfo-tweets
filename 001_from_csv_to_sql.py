#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  3 13:26:45 2021

@author: Tito
"""

import glob
import pandas as pd
import sqlite3

conn = sqlite3.connect('/Volumes/TOSHIBA EXT/choronavirus/data_twitter/data_sql/streaming_english.db')
c = conn.cursor()

path = r'/Volumes/TOSHIBA EXT/choronavirus/data_twitter/data_csv'
filenames = glob.glob(path + "/*.csv")

sql_filename = "my_foo.sql"

filename = "/Volumes/TOSHIBA EXT/choronavirus/data_twitter/data_csv/202001311428_stream.json_00.plit.csv"

for filename in filenames:
    with pd.read_csv(filename, chunksize=100) as reader:
        for chunk in reader:
            chunk.to_sql(sql_filename, conn, if_exists='append', index=False)

# Ask for all tables in sql server        
c.execute("SELECT name FROM sqlite_master WHERE type='table';")
print(c.fetchall())

# Ask for first 5 records in a given table:
c.execute("select * from 'my_foo.sql' limit 5;")
results = c.fetchall()
print(results)
