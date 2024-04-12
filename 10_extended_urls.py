#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 18 10:03:54 2021

@author: Tito
"""


import requests
import pandas as pd

url = "https://t.co/mmxMbomepo"

def unshorten_url(url):
    if pd.isna(url):
        return "None"
    else:
        response = requests.head(url, allow_redirects=True).url
        return response

df = pd.read_csv('/Volumes/TOSHIBA EXT/choronavirus/data_twitter/to_process/shorted_url.csv')

foo = df.loc[:200].copy()

foo.loc[:, "extended_url"] = foo["shortened_urls"].apply(unshorten_url)

print(foo)
