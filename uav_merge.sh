# Raw UAV sfm goes here
INPUT_DIRECTORY=$1

# Merged UAV go here
OUTPUT_DIRECTORY=$2

# Plot boundary directory goes here
PLOT_DIRECTORY=$3

# Coordinates for the initial point clouds
PREFIX=$4

LASTOOLS_SINGULARITY="/data/gpfs/assoc/gears/scratch/thartsook/gears-singularity_gears-lastools.sif"


mkdir -p "$OUTPUT_DIRECTORY"/"$PREFIX"

cd $INPUT_DIRECTORY

for directory in */; do
    plot_id=${directory:0:4}
    singularity exec $LASTOOLS_SINGULARITY lasmerge -i "$directory"/*.laz -o "$plot_id"_UAV_merged.las -odir "$OUTPUT_DIRECTORY"/"$PREFIX"
done
