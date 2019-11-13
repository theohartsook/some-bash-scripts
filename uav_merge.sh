# Raw UAV sfm goes here
INPUT_DIRECTORY=/home/theo/Documents/sfm_merge_test/raw_uav_pc

# Plot boundary directory goes here
PLOT_DIRECTORY=/home/theo/Documents/sfm_merge_test/boundaries

# Temp directory
TEMP_DIRECTORY=/home/theo/Documents/sfm_merge_test/temp

# Merged and clipped UAV go here
OUTPUT_DIRECTORY=/home/theo/Documents/sfm_merge_test/output

# Coordinates for the initial point clouds
UTM=11n
#UTM=${4:-10n}

mkdir -p "$TEMP_DIRECTORY"/merged
mkdir -p "$TEMP_DIRECTORY"/reproject
mkdir -p "$OUTPUT_DIRECTORY"/merged
mkdir -p "$OUTPUT_DIRECTORY"/clipped

cd $INPUT_DIRECTORY

for directory in */; do
    plot_id=${directory:0:4}
    lasmerge -i "$directory"/*.laz -o "$plot_id"_UAV_merged.las -odir "$TEMP_DIRECTORY"/merged
done

cd $TEMP_DIRECTORY/merged
for filename in *.las; do
    plot_id=${filename:0:4}
    las2las -i $filename -utm 11n -wgs84 -target_epsg 3310 -odir "$TEMP_DIRECTORY"/reproject
done

cd $TEMP_DIRECTORY/reproject
for filename in *.las; do
    plot_id=${filename:0:4}
    lasnoise -i $filename -remove_noise -odir "$OUTPUT_DIRECTORY"/merged
done

cd "$OUTPUT_DIRECTORY"/merged
for filename in *.las; do
    plot_id=${filename:0:4}
    lasclip -i $filename -poly "$PLOT_DIRECTORY"/"$plot_id".shp -o "$plot_id"_UAV_clipped.las -odir "$OUTPUT_DIRECTORY"/clipped
done

# TODOS
# set projection settings for point cloud merge
# check that bounding boxes make sense
