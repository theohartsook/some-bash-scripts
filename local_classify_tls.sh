LAS_DIRECTORY=/home/theo/Desktop/2_34by34m
OUTPUT_DIRECTORY=/home/theo/Desktop/classified_tls
PREFIX=2017
NUM_CORES=16
TEMP_DIRECTORY=/home/theo/Desktop/"$PREFIX"_temp
mkdir -p "$OUTPUT_DIRECTORY"/"$PREFIX"
mkdir -p "$TEMP_DIRECTORY"/input

cp $LAS_DIRECTORY/*.las "$TEMP_DIRECTORY"/input

lasindex -i "$TEMP_DIRECTORY"/input/*.las -cpu64

# Classify ground
ls -d "$TEMP_DIRECTORY"/input/*.las >> "$TEMP_DIRECTORY"/input.txt
mkdir -p "$TEMP_DIRECTORY"/ground
lasground -lof "$TEMP_DIRECTORY"/input.txt -olas -odix _ground -ultra_fine -step 3 -cores $NUM_CORES -odir "$TEMP_DIRECTORY"/ground -cpu64
	
# Get height
rm "$TEMP_DIRECTORY"/input.txt
ls -d "$TEMP_DIRECTORY"/ground/*_ground.las >> "$TEMP_DIRECTORY"/ground.txt	
mkdir -p $TEMP_DIRECTORY"/height"
lasheight -lof "$TEMP_DIRECTORY"/ground.txt -drop_below 0 -drop_above 100 -replace_z -cores $NUM_CORES -olas -odix _norm -odir "$OUTPUT_DIRECTORY"/"$PREFIX" -cpu64

rm -r $TEMP_DIRECTORY

