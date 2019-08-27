#!/bin/bash

NAME=$1 # either type the name for the folder when calling the script
        # or replace $1 with the name you want
OUTPATH=/home/theo/Documents/P4_RTK/DJI/DSM/$NAME
USGS=w001001.adf
MASK=pv1.shp
TIF=$NAME.tif

# cd to directory with the USGS .adf and the clip shapefile
cd /home/theo/Documents/P4_RTK/Paradise\ Valley/grdn42w118_13

if [ -d "$OUTPATH" ]
then
    echo "$NAME already exists."
else
    mkdir $OUTPATH
    gdalwarp -cutline $MASK -crop_to_cutline -co TFW=YES $USGS $OUTPATH/$TIF
fi

# TODO
# better way to get to .adf files
# automatically make mask polygon
# add exception handling for duplicate names
# better file navigation
