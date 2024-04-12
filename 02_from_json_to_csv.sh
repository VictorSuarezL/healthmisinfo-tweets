mkdir data_twitter/splited
mkdir data_twitter/unzip

for fname in data_twitter/*.zip; do

    # unzip $fname -d data_twitter/unzip

    # mv -v ./data_twitter/unzip/*/*_stream.json data_twitter/
    # rmdir data_twitter/unzip/*

    cd data_twitter/

    for fnamei in *_stream.json; do
        sed -E '/^{.*$/!d' $fnamei |
        gsplit --verbose -d -l 100000 --additional-suffix=.json - ./splited/"${fnamei}_"
        # TODO añadir aquí el script de python,
        # también mover aquí los archivos para
        # pueda iterar
        rm $fnamei
    done

    cd ../

    python scripts/ba.py data_twitter/splited/*.json

    mv -v data_twitter/splited/*.csv data_twitter/data_csv

done

rmdir -r data_twitter/splited
rmdir -r data_twitter/unzip
