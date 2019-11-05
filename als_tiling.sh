# Instructions
# Arguments
# This takes the input and output directories as arguments.
    # Set those in the SBATCH script.
    #$1 = input directory
    #$2 = output directory
    #$3 = prefix (e.g. Plumas, Walker, Tahoe, Ferguson)
    #$4 = UTM zone (e.g. 10n, 11n)
    #$5 = Number of cores to use for processing (32 when using a full node)
#
# Variables
# PREFIX is for the outputs. Not fully implemented yet.
# TEMP_DIRECTORY is where all the intermediate data goes. Needs a lot of space.
# NUM_CORES sets how many threads you can use for parallel processing.
    # Set it to 32 for best results
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

LAS_DIRECTORY=$1
TEMP_DIRECTORY="/data/gpfs/assoc/gears/scratch/thartsook/"$3"_temp"
OUTPUT_DIRECTORY=$2
LASTOOLS_SINGULARITY="gears-singularity_gears-lastools.sif"
mkdir -p $2"/buffered"
mkdir -p $2"/seamless" 
mkdir -p $TEMP_DIRECTORY"/input"
PREFIX=$3
UTM=${4:-10n}
NUM_CORES=${5:-32}

cp $LAS_DIRECTORY/* $TEMP_DIRECTORY"/input"

singularity exec $LASTOOLS_SINGULARITY lasindex -i "$TEMP_DIRECTORY"/input/*.las -cpu64

# reproject
ls -d "$TEMP_DIRECTORY"/input/*.las >> "$TEMP_DIRECTORY"/input.txt
mkdir -p $TEMP_DIRECTORY"/reproject"

singularity exec $LASTOOLS_SINGULARITY las2las  -lof "$TEMP_DIRECTORY"/input.txt -utm $UTM -wgs84 -target_epsg 3310 -odir $TEMP_DIRECTORY"/reproject" -olas -odix _reproject -cpu64

# Convert to LAS 1.4

rm "$TEMP_DIRECTORY"/input.txt
ls -d "$TEMP_DIRECTORY"/reproject/*_reproject.las >> "$TEMP_DIRECTORY"/reproject.txt

mkdir -p $TEMP_DIRECTORY"/conversion"
singularity exec $LASTOOLS_SINGULARITY las2las -lof "$TEMP_DIRECTORY"/reproject.txt -set_version 1.4 -odix _14 -odir $TEMP_DIRECTORY"/conversion" -cpu64

ls -d "$TEMP_DIRECTORY"/conversion/*14.las >> "$TEMP_DIRECTORY"/conversion.txt

singularity exec $LASTOOLS_SINGULARITY lasindex -lof $TEMP_DIRECTORY/conversion.txt -cpu64

# build tiles
rm "$TEMP_DIRECTORY"/reproject.txt

mkdir -p $TEMP_DIRECTORY"/tiles"
singularity exec $LASTOOLS_SINGULARITY lastile -lof $TEMP_DIRECTORY/conversion.txt -files_are_flightlines -rescale 0.01 0.01 0.01 -tile_size 1000 -buffer 100 -odir $TEMP_DIRECTORY"/tiles" -o $PREFIX"_tile.las" -cpu64

# lasnoise
rm "$TEMP_DIRECTORY"/conversion.txt
ls -d "$TEMP_DIRECTORY"/tiles/*.las >> "$TEMP_DIRECTORY"/tiles.txt
mkdir -p $TEMP_DIRECTORY"/denoise"
singularity exec $LASTOOLS_SINGULARITY lasnoise -lof "$TEMP_DIRECTORY"/tiles.txt -remove_noise -olas -odix _denoised -cores $NUM_CORES -olas -odir $TEMP_DIRECTORY"/denoise" -cpu64
	
    
# Classify ground
rm "$TEMP_DIRECTORY"/tiles.txt
ls -d "$TEMP_DIRECTORY"/denoise/*_denoised.las >> "$TEMP_DIRECTORY"/denoised.txt
mkdir -p $TEMP_DIRECTORY"/ground1"
singularity exec $LASTOOLS_SINGULARITY lasground -lof "$TEMP_DIRECTORY"/denoised.txt -olas -odix _ground -ultra_fine -step 3 -cores $NUM_CORES -odir $TEMP_DIRECTORY"/ground1" -cpu64
	
# Get height
rm "$TEMP_DIRECTORY"/denoised.txt
ls -d "$TEMP_DIRECTORY"/ground1/*_ground.las >> "$TEMP_DIRECTORY"/ground.txt	
mkdir -p $TEMP_DIRECTORY"/height"
singularity exec $LASTOOLS_SINGULARITY lasheight -lof "$TEMP_DIRECTORY"/ground.txt -drop_below 0 -drop_above 100 -cores $NUM_CORES -olas -odix _norm -odir $TEMP_DIRECTORY"/height" -cpu64

# Classify
# "-ground_offset 0.2 -olaz"	
rm "$TEMP_DIRECTORY"/ground.txt
ls -d "$TEMP_DIRECTORY"/height/*_norm.las >> "$TEMP_DIRECTORY"/norm.txt
singularity exec $LASTOOLS_SINGULARITY lasclassify -lof "$TEMP_DIRECTORY"/norm.txt -ground_offset 0.2 -cores $NUM_CORES -olas -odix _classify -odir "$OUTPUT_DIRECTORY"/buffered -cpu64

# Remove buffer for a second set of tiles
rm "$TEMP_DIRECTORY"/norm.txt
ls -d "$OUTPUT_DIRECTORY"/buffered/*_classify.las >> "$TEMP_DIRECTORY"/buffered.txt
singularity exec $LASTOOLS_SINGULARITY lastile -lof "$TEMP_DIRECTORY"/buffered.txt -remove_buffer -odix _seamless -odir "$OUTPUT_DIRECTORY"/seamless -cpu64


#rm -r "$TEMP_DIRECTORY"/*
