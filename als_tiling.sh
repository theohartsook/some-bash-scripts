# cd to my working directory
cd /data/gpfs/assoc/gears/scratch/thartsook

# tile info
PREFIX="USCAYF20180722f1a1"
LAS_DIRECTORY=$1
#"/data/gpfs/assoc/gears/scratch/thartsook/als_test_registration/als_prefire"
TEMP_DIRECTORY="/data/gpfs/assoc/gears/scratch/thartsook/als_test_registration/registration_temp/"
BUFFER_DIRECTORY=$2
mkdir -p $2"/buffered"
mkdir -p $2"/seamless" 
#"/data/gpfs/assoc/gears/scratch/thartsook/als_test_registration/output"

mkdir -p $TEMP_DIRECTORY
#"/data/gpfs/assoc/gears/scratch/thartsook/als_test_registration/registration_temp"


singularity exec lastools_build_9_19_license.sif lasindex -i "$LAS_DIRECTORY"/*.las

# reproject
ls -d "$LAS_DIRECTORY/"*.las >> "$TEMP_DIRECTORY"/input.txt
mkdir -p $TEMP_DIRECTORY"/reproject"

singularity exec lastools_build_9_19_license.sif las2las -lof "$TEMP_DIRECTORY"/input.txt -utm 11n -wgs84 -target_epsg 3310 -odir $TEMP_DIRECTORY"/reproject" -olas -odix _reproject

# Convert to LAS 1.4

rm "$TEMP_DIRECTORY"/input.txt
ls -d "$TEMP_DIRECTORY/"reproject/*_reproject.las >> "$TEMP_DIRECTORY"/reproject.txt

mkdir -p $TEMP_DIRECTORY"/conversion"
singularity exec lastools_build_9_19_license.sif las2las -lof "$TEMP_DIRECTORY"/reproject.txt -set_version 1.4 -odix _14 -odir $TEMP_DIRECTORY"/conversion"

ls -d "$TEMP_DIRECTORY"conversion/*14.las >> "$TEMP_DIRECTORY"/conversion.txt

singularity exec lastools_build_9_19_license.sif lasindex -lof $TEMP_DIRECTORY/conversion.txt

# build tiles
rm "$TEMP_DIRECTORY"/reproject.txt

mkdir -p $TEMP_DIRECTORY"/tiles"
singularity exec lastools_build_9_19_license.sif lastile -lof $TEMP_DIRECTORY/conversion.txt -files_are_flightlines -rescale 0.01 0.01 0.01 -tile_size 500 -buffer 50 -odir $TEMP_DIRECTORY"/tiles" -o $PREFIX"_tile.las"

# lasnoise
rm "$TEMP_DIRECTORY"/conversion.txt
ls -d "$TEMP_DIRECTORY/"tiles/*.las >> "$TEMP_DIRECTORY"/tiles.txt
mkdir -p $TEMP_DIRECTORY"/denoise"
singularity exec lastools_build_9_19_license.sif lasnoise -lof "$TEMP_DIRECTORY"/tiles.txt -remove_noise -olas -odix _denoised -olas -odir $TEMP_DIRECTORY"/denoise"
	
    
# Classify ground
rm "$TEMP_DIRECTORY"/tiles.txt
ls -d "$TEMP_DIRECTORY/"denoise/*_denoised.las >> "$TEMP_DIRECTORY"/denoised.txt
mkdir -p $TEMP_DIRECTORY"/ground1"
singularity exec lastools_build_9_19_license.sif lasground -lof "$TEMP_DIRECTORY"/denoised.txt -olas -odix _ground -ultra_fine -step 3 -odir $TEMP_DIRECTORY"/ground1"
	
# Get height
rm "$TEMP_DIRECTORY"/denoised.txt
ls -d "$TEMP_DIRECTORY/"ground1/*_ground.las >> "$TEMP_DIRECTORY"/ground.txt	
mkdir -p $TEMP_DIRECTORY"/height"
singularity exec lastools_build_9_19_license.sif lasheight	-lof "$TEMP_DIRECTORY"/ground.txt -drop_below 0 -drop_above 100 -olas -odix _norm -odir $TEMP_DIRECTORY"/height"

# Classify
# "-ground_offset 0.2 -olaz"	
rm "$TEMP_DIRECTORY"/ground.txt
ls -d "$TEMP_DIRECTORY/"height/*_norm.las >> "$TEMP_DIRECTORY"/norm.txt
singularity exec lastools_build_9_19_license.sif lasclassify -lof "$TEMP_DIRECTORY"/norm.txt -ground_offset 0.2 -olas -odix _classify -odir "$BUFFER_DIRECTORY"/buffered

# Remove buffer for a second set of tiles
rm "$TEMP_DIRECTORY"/norm.txt
ls -d "$BUFFER_DIRECTORY/"buffered/*_classify.las >> "$TEMP_DIRECTORY"/buffered.txt
singularity exec lastools_build_9_19_license.sif lastile -lof "$TEMP_DIRECTORY"/buffered.txt -remove_buffer -odix _seamless -odir "$BUFFER_DIRECTORY"/seamless

# Run lasinfo to prepare for plot extraction
singularity exec lastools_build_9_19_license.sif lasinfo -lof "$TEMP_DIRECTORY"/buffered.txt
rm "$TEMP_DIRECTORY"/buffered.txt
ls -d "$BUFFER_DIRECTORY/"seamless/*seamless.las >> "$TEMP_DIRECTORY"/seamless.txt
singularity exec lastools_build_9_19_license.sif lasinfo -lof "$TEMP_DIRECTORY"/seamless.txt

#rm -r "$TEMP_DIRECTORY"/*
