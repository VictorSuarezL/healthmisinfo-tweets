cd data_twitter/data_1/

for fnamei in *28_stream.json; do
    sed -E '/^{.*$/!d' $fnamei |
    gsplit --verbose -d -l 10000 --additional-suffix=.json - splited"${fnamei}_"
    rm $fnamei
done
