#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 15 12:35:01 2021

@author: Tito
"""

import botometer
import pandas as pd
from datetime import datetime
import glob

rapidapi_key = "29ac48149fmsh30b12c4e89e8c80p1afacdjsn41e53784d790"
twitter_app_auth = {
    'consumer_key': 'XXXXX',
    'consumer_secret': 'XXXXX',
    'access_token': 'XXXXX',
    'access_token_secret': 'XXXXX',
  }

bom = botometer.Botometer(wait_on_ratelimit=True,
                          rapidapi_key=rapidapi_key,
                          **twitter_app_auth)

user_id_dir = "/Volumes/TOSHIBA EXT/choronavirus/data_twitter/to_process/user_id_tweets_in_english.csv"

user_id_data = pd.read_csv(user_id_dir)

botometer_result_dir = "/Volumes/TOSHIBA EXT/choronavirus/data_twitter/to_process/botometer_result/"

try:
    botometer_result = pd.concat(map(pd.read_csv, glob.glob(botometer_result_dir + "*.csv")))
    # botometer_result = pd.read_csv(botometer_result_dir)
    filtered_out_user_id = pd.merge(
        user_id_data, botometer_result,
        how='outer', indicator=True, suffixes=('_foo','')).query(
        '_merge == "left_only"').drop("_merge", axis = 1)
    
except:
    filtered_out_user_id = user_id_data

accounts = filtered_out_user_id["user_id"].astype(int)

df_list = []
counter = 0

for screen_name, result in bom.check_accounts_in(accounts):
    
    if counter == 5:
        break
    
    print(screen_name)
    # Do stuff with `screen_name` and `result`
    result["user_id"]=screen_name       
    dictionary_copy = result.copy()
    df_list.append(dictionary_copy)
    # output = pd.json_normalize(result)
    # output2 = json.load(result)
    # print(output)
    # df=df.append(output2)
    # with open(my_csv, 'a') as f:
    #     df.to_csv(f, header=f.tell()==0)
    counter += 1

timestamp = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")

print("We are here: {}!!!".format(timestamp))

filename = botometer_result_dir + timestamp + "_botometer_result.csv"

df = pd.concat([pd.json_normalize(l) for l in df_list])

df.to_csv(filename)

print("Success! :)")

