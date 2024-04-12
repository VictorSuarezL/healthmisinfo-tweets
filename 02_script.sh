for fname in 2*.json
do
   # echo "Reading $fname..."

   dos2unix -v $fname | dos2unix > temp.json

   cat temp.json | sed '/^$/d' > no_empty_lines.json

   rm temp.json

   # gsplit --verbose -d -l 10000 --additional-suffix=.json no_empty_lines.json ./splited/"${fname}_"
   gsplit -e --verbose -d -n l/2 --additional-suffix=.json no_empty_lines.json ./splited/"${fname}_".json
   rm no_empty_lines.json

   # rm $fname
done
