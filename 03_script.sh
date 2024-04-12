# cat try.json | sed '/^\$/d' > cero.json
#
# cat try.json | sed 's/\r$//' > uno.json
#
# cat try.json | sed "s/$(printf '\r')\$//" > dos.json
#
# cat dos.json | sed '/^$/d' > dos_uno.json
#
# cat foo.json | sed "s/$(printf '\r')\$//" | sed '/^$/d' |
# gsplit --verbose -d -n l/6 --additional-suffix=.json no_empty_lines.json ./splited/"${fname}_"

for fname in 2*.json; do
  sed "s/$(printf '\r')\$//" $fname |
  sed '/^$/d' |
  gsplit --verbose -d -l 1000000 --additional-suffix=.json - ./splited/"${fname}_"
done
  #statements
