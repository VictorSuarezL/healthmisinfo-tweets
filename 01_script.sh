#!/bin/bash

# if [ -d "./splited" ]
# then
#     echo "Directory splited exists."
# else
#     echo "Directory splited does not exists."
#     mkdir splited
# fi

for fname in 2*.json
do
   # echo "Reading $fname..."

   cat $fname | dos2unix -v | dos2unix > temp.json

   cat temp.json | sed '/^$/d' > no_empty_lines.json

   rm temp.json

   # gsplit --verbose -d -l 10000 --additional-suffix=.json no_empty_lines.json ./splited/"${fname}_"
   gsplit -e --verbose -d -n l/2 --additional-suffix=.json no_empty_lines.json ./splited/"${fname}_".json
   rm no_empty_lines.json

   # rm $fname
done

# cat foo.json | dos2unix | dos2unix > temp.json
#
# cat temp.json | sed '/^$/d' > ./temp/test.json
#
# rm ./temp/test.json
# # sed -i '/^$/d' ./temp/test.json
#
# gsplit -d -l 100000 --additional-suffix=.json temp.json ./splited/baba_
