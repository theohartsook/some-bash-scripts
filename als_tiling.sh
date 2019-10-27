# Instructions
# Arguments
# This takes the input and output directories as arguments.
    # Set those in the SBATCH script.
#
# Variables
# PREFIX is for the outputs. Not fully implemented yet.
# TEMP_DIRECTORY is where all the intermediate data goes. Needs a lot of space.
# NUM_CORES sets how many threads you can use for parallel processing.
    # Use nproc to use all threads available or set it to an explicit number.
# LASTOOLS_SINGULARITY is the location of the newest LASTools image.
#
# Special notes
# Reproject step needs to be very explicit. Make sure -utm and -wgs84 are accurate.
    # Use epsg code for the target projection.
# I don't recommend making tiles much bigger than 500 meters at the beginning.
    # There's an additional lastile at the end if you want to make bigger tiles.




# Preparation
cd /data/gpfs/assoc/gears/scratch/thartsook
singularity pull shub://gearslaboratory/gears-singularity:gears-lastools

PREFIX="USCAYF20180722f1a1"
LAS_DIRECTORY=$1
TEMP_DIRECTORY="/data/gpfs/assoc/gears/scratch/thartsook/tiling/temp"
OUTPUT_DIRECTORY=$2
LASTOOLS_SINGULARITY="gears-singularity_gears-lastools.sif"
mkdir -p $2"/buffered"
mkdir -p $2"/seamless" 
mkdir -p $TEMP_DIRECTORY"/input"

NUM_CORES=nproc

cp $LAS_DIRECTORY/* $TEMP_DIRECTORY"/input"

singularity exec $LASTOOLS_SINGULARITY lasindex -i "$TEMP_DIRECTORY"/input/*.las

# reproject
ls -d "$TEMP_DIRECTORY"/input/*.las >> "$TEMP_DIRECTORY"/input.txt
mkdir -p $TEMP_DIRECTORY"/reproject"

singularity exec $LASTOOLS_SINGULARITY las2las -lof "$TEMP_DIRECTORY"/input.txt -utm 10n -wgs84 -target_epsg 3310 -odir $TEMP_DIRECTORY"/reproject" -olas -odix _reproject

# Convert to LAS 1.4

rm "$TEMP_DIRECTORY"/input.txt
ls -d "$TEMP_DIRECTORY/"reproject/*_reproject.las >> "$TEMP_DIRECTORY"/reproject.txt

mkdir -p $TEMP_DIRECTORY"/conversion"
singularity exec $LASTOOLS_SINGULARITY las2las -lof "$TEMP_DIRECTORY"/reproject.txt -set_version 1.4 -odix _14 -odir $TEMP_DIRECTORY"/conversion"

ls -d "$TEMP_DIRECTORY"/conversion/*14.las >> "$TEMP_DIRECTORY"/conversion.txt

singularity exec $LASTOOLS_SINGULARITY lasindex -lof $TEMP_DIRECTORY/conversion.txt

# build tiles
rm "$TEMP_DIRECTORY"/reproject.txt

mkdir -p $TEMP_DIRECTORY"/tiles"
singularity exec $LASTOOLS_SINGULARITY lastile -lof $TEMP_DIRECTORY/conversion.txt -files_are_flightlines -rescale 0.01 0.01 0.01 -tile_size 500 -buffer 50 -odir $TEMP_DIRECTORY"/tiles" -o $PREFIX"_tile.las"

# lasnoise
rm "$TEMP_DIRECTORY"/conversion.txt
ls -d "$TEMP_DIRECTORY/"tiles/*.las >> "$TEMP_DIRECTORY"/tiles.txt
mkdir -p $TEMP_DIRECTORY"/denoise"
singularity exec $LASTOOLS_SINGULARITY lasnoise -lof "$TEMP_DIRECTORY"/tiles.txt -remove_noise -olas -odix _denoised -cores $NUM_CORES -olas -odir $TEMP_DIRECTORY"/denoise"
	
    
# Classify ground
rm "$TEMP_DIRECTORY"/tiles.txt
ls -d "$TEMP_DIRECTORY/"denoise/*_denoised.las >> "$TEMP_DIRECTORY"/denoised.txt
mkdir -p $TEMP_DIRECTORY"/ground1"
singularity exec $LASTOOLS_SINGULARITY lasground -lof "$TEMP_DIRECTORY"/denoised.txt -olas -odix _ground -ultra_fine -step 3 -cores $NUM_CORES -odir $TEMP_DIRECTORY"/ground1"
	
# Get height
rm "$TEMP_DIRECTORY"/denoised.txt
ls -d "$TEMP_DIRECTORY/"ground1/*_ground.las >> "$TEMP_DIRECTORY"/ground.txt	
mkdir -p $TEMP_DIRECTORY"/height"
singularity exec $LASTOOLS_SINGULARITY lasheight -lof "$TEMP_DIRECTORY"/ground.txt -drop_below 0 -drop_above 100 -cores $NUM_CORES -olas -odix _norm -odir $TEMP_DIRECTORY"/height"

# Classify
# "-ground_offset 0.2 -olaz"	
rm "$TEMP_DIRECTORY"/ground.txt
ls -d "$TEMP_DIRECTORY/"height/*_norm.las >> "$TEMP_DIRECTORY"/norm.txt
singularity exec $LASTOOLS_SINGULARITY lasclassify -lof "$TEMP_DIRECTORY"/norm.txt -ground_offset 0.2 -cores $NUM_CORES -olas -odix _classify -odir "$OUTPUT_DIRECTORY"/buffered

# Remove buffer for a second set of tiles
rm "$TEMP_DIRECTORY"/norm.txt
ls -d "$OUTPUT_DIRECTORY/"buffered/*_classify.las >> "$TEMP_DIRECTORY"/buffered.txt
singularity exec $LASTOOLS_SINGULARITY lastile -lof "$TEMP_DIRECTORY"/buffered.txt -remove_buffer -odix _seamless -odir "$OUTPUT_DIRECTORY"/seamless



# Lastile to build bigger tiles (this would be something you set by hand)
# singularity exec $LASTOOLS_SINGULARITY lastile -lof /data/gpfs/assoc/gears/scratch/thartsook/als_test_registration/reproject_als_postfire_output/seamless.txt -cores 10 -tile_size 1000 -odir /data/gpfs/assoc/gears/scratch/thartsook/als_test_registration/reproject_als_postfire_output/merged

#rm -r "$TEMP_DIRECTORY"/*

#todos
# standardize quotations
