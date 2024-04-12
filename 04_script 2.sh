for fname in 2*.json; do
  cat $fname |
  sed "s/$(printf '\r')\$//" |
  sed '/^$/d' |
  gsplit --verbose -d -l 1000000 --additional-suffix=.json - ./splited/"${fname}_"
done
