#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 17 21:22:30 2021

@author: Tito
"""

import re

file_dir = "/Volumes/TOSHIBA EXT/data_1/202001311428_stream.json"

pattern = "1223246048669229058"

for line in open(file_dir):
    for match in re.finditer(pattern, line):
        print(line)
        
        