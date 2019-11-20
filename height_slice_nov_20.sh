INPUT_DIRECTORY=/home/theo/Desktop/classified_tls/2018
OUTPUT_DIRECTORY=/home/theo/Desktop/height_slice/2018
cd $INPUT_DIRECTORY
for filename in *.las; do
    mkdir -p "$OUTPUT_DIRECTORY"/"$filename"
    i=0
    while [ $i -lt 100 ]
    do
        j=$[$i+2]
        las2las -i $filename -keep_z $i $j -odix _"$i"_"$j" -odir "$OUTPUT_DIRECTORY"/"$filename"
        i=$[$j]
    done
done

