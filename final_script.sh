for fname in 2*.json; do
    cat $fname | dos2unix -v |
    # dos2unix |
    sed '/^$/d' |
    gsplit --verbose -d -l 1000000 --additional-suffix=.json - ./splited/"${fname}_"
done
