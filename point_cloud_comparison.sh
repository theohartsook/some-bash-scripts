#!/usr/bin/env bash

# Point cloud comparisons shell script. The goal is to be able to register
# every plot multiple times. First year should be tls to als. Second year will
# tls, uav, and als to first year als.

tls_a_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_tls_a
tls_a_2_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_tls_a_2
als_a_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_als_a
uav_b_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_uav_b
uav_b_2_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_uav_b_2
# This is the real directory on HPC
#tls_a_dir=/data/gpfs/assoc/gears/lidarchange/TLS_Output/2017/1_LasVer1.2/2_Clipped/2_34x34m
#tls_a_2_dir=where should this go?
#tls_b_dir=/data/gpfs/assoc/gears/lidarchange/TLS_Output/2018/1_LasVer1.2/2_Clipped/2_34x34m
#uav_b_dir=
#uav_b_2_dir=output for registered uav
#als_a_dir=
#als_b_dir=

cd $tls_a_dir
# register tls_a to als_a
for filename in *.las; do
    plot_id=${filename:0:4}
    als_ref=$plot_id"_ALS_clip.las"
    cloudcompare.CloudCompare -C_EXPORT_FMT LAS -O $filename -O $als_a_dir/$als_ref -ICP -MIN_ERROR_DIFF 1e-8 -ADJUST_SCALE -RANDOM_SAMPLING_LIMIT 1000000000

    #echo "Export newly registered tls to tls_a_2_dir"
    #echo "Cloudcompare registration of newly registered tla to tls_b, uav_b, als_b"
    #echo "Export registered point cloud"
    #echo "Point cloud comparisons"
done

# export registered tls_a
for filename in *_REGISTERED_*.las; do
    plot_id=${filename:0:4}
    output_filename=$plot_id"_TLS_a_2.las"
    mv $filename $tls_a_2_dir/$output_filename
done

# register uav_b to registered tls (tls_a_2)
cd $tls_a_2_dir
for filename in *.las; do
    plot_id=${filename:0:4}
    uav_b_ref=$plot_id"_UAV_clip.las"
    cloudcompare.CloudCompare -C_EXPORT_FMT LAS -O $uav_b_dir/$uav_b_ref -O $filename -ICP -MIN_ERROR_DIFF 1e-8 -ADJUST_SCALE -RANDOM_SAMPLING_LIMIT 1000000000
done

# export registered uav_b
for filename in *_REGISTERED_*.las; do
    plot_id=${filename:0:4}
    output_filename=$plot_id"_UAV_b_2.las"
    mv $filename $uav_b_2_dir/$output_filename
done

# TODOs
# edit the plot id and als_ref to work for 3 digit and 5 digit plot ids
# update the loop so it cd's into the output directory
# add wildcard so for loops are .las or .laz
# rename output files to something specific
