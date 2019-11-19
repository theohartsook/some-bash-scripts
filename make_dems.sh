# las2dem for bare earth models
# Input
# Classified point clouds

# Preparation
PREFIX="tahoe"
LAS_DIRECTORY=$1/seamless
OUTPUT_DIRECTORY=$2
LASTOOLS_SINGULARITY="gears-singularity_gears-lastools.sif"
TEMP_DIRECTORY="/data/gpfs/assoc/gears/scratch/thartsook/dem_creation/temp"

mkdir -p $TEMP_DIRECTORY
#mkdir -p "$LAS_DIRECTORY"/1km_seamless

#ls -d "$LAS_DIRECTORY"/*.las >> "$TEMP_DIRECTORY"/tile_change.txt

#singularity exec $LASTOOLS_SINGULARITY lastile -lof "$TEMP_DIRECTORY"/input.txt -cores 32 -tile_size 1000 -odir "$LAS_DIRECTORY"/1km_seamless

#rm "$TEMP_DIRECTORY"/tile_change.txt

ls -d "$LAS_DIRECTORY"/*.las >> "$TEMP_DIRECTORY"/input.txt

mkdir -p "$OUTPUT_DIRECTORY"/individual

singularity exec $LASTOOLS_SINGULARITY blast2dem -lof "$TEMP_DIRECTORY"/input.txt -otif -epsg 3310 -cores 32 -keep_class 2 -step 1 -odir "$OUTPUT_DIRECTORY"/individual

rm -r $TEMP_DIRECTORY

# TODOs
# add a 1m ground offset to this and work into CMS workflow

ls -d /home/theo/Desktop/11n/individual/*.tif >> 11n.txt
ls -d /home/theo/Desktop/10n/individual/*.tif >> 10n.txt


gdalbuildvrt -input_file_list tahoe_dem.txt dem_mosaic.vrt
gdal_translate -of GTiff dem_mosaic.vrt mosaic.tif
