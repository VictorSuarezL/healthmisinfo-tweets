#!/bin/bash

cd /Volumes/TOSHIBA\ EXT/choronavirus/data_twitter

for fname in *.zip; do

    mkdir unzip

    unzip $fname -d unzip/
    mv -v unzip/*/*_stream.json ./

    for fnamei in *_stream.json; do
        tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

        sed -E '/^{.*$/!d' $fnamei |
        gsplit --verbose -d -l 100000 --additional-suffix=.plit - $tmp_dir/"${fnamei}_"
        rm -rf $fnamei

        python3 /Volumes/TOSHIBA\ EXT/choronavirus/scripts/ba.py $tmp_dir/*.plit
        mv -v $tmp_dir/*.csv data_csv/

        rm -rf $tmp_dir
    done

    mv -v $fname data_raw/

    rm -rf ./unzip

done
