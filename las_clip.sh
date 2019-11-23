LAS_DIRECTORY=$1
OUTPUT_DIRECTORY=$2
SHAPEFILE_DIRECTORY=$3
LASTOOLS_SINGULARITY="/data/gpfs/assoc/gears/scratch/thartsook/gears-singularity_gears-lastools.sif"
PREFIX=$4

mkdir -p $OUTPUT_DIRECTORY

cd $LAS_DIRECTORY

for filename in *.las; do
    plot_id=${filename:0:4}
    clip_box="$SHAPEFILE_DIRECTORY"/*"$plot_id".shp
    singularity exec $LASTOOLS_SINGULARITY lasclip -i $filename -poly $clip_box -odix _clip -odir $OUTPUT_DIRECTORY 
done
