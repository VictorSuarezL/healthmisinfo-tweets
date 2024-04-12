for fname in *.txt
do
   gsplit -l 5 --additional-suffix=.txt $fname ./splited/"${fname}_"
done
