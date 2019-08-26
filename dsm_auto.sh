#!/bin/bash

# Instructions
# cd to directory with the USGS .adf and the clip shapefile
NAME=$1 # either type the name for the folder when calling the script
        # or replace $1 with the name you want
OUTPATH=/home/theo/Documents/P4_RTK/DJI/DSM/$NAME
USGS=w001001.adf
MASK=clipbox.shp
DSM=test.tif

if [ -d "$OUTPATH" ]
then
    echo "$NAME already exists."
else
    mkdir $OUTPATH
    gdalwarp -cutline $MASK -crop_to_cutline $USGS $OUTPATH/$DSM
    listgeo -tfw $OUTPATH/$DSM
fi

# TODO
# better way to get to .adf files
# automatically make mask polygon
