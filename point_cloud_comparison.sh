#!/usr/bin/env bash

# Point cloud comparisons shell script. The goal is to be able to register
# every plot multiple times. First year should be tls to als. Second year will
# tls, uav, and als to first year als.

tls_a_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_tls_a
tls_a_2_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_als_a_2
als_a_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_als_a
# This is the real directory on HPC
#tls_a_dir = /data/gpfs/assoc/gears/lidarchange/TLS_Output/2017/1_LasVer1.2/2_Clipped/2_34x34m
#tls_a_2_dir = where should this go?
#tls_b_dir = /data/gpfs/assoc/gears/lidarchange/TLS_Output/2018/1_LasVer1.2/2_Clipped/2_34x34m
#uav_b_dir = 
#als_a_dir =
#als_b_dir =

cd $tls_a_dir
for filename in *.las; do
    plot_id=${filename:0:4}
    als_ref=$plot_id"_ALS_clip.las"
    cloudcompare.CloudCompare -C_EXPORT_FMT LAS -O $filename -O $als_a_dir/$als_ref -ICP -MIN_ERROR_DIFF 1e-8 -ADJUST_SCALE -RANDOM_SAMPLING_LIMIT 1000000000

    #echo "Export newly registered tls to tls_a_2_dir"
    #echo "Cloudcompare registration of newly registered tla to tls_b, uav_b, als_b"
    #echo "Export registered point cloud"
    #echo "Point cloud comparisons"
done

# TODOs
# edit the plot id and als_ref to work for 3 digit and 5 digit plot ids
# update the loop so it cd's into the output directory
