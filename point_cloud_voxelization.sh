#!/usr/bin/env bash


tls_a_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_tls_a
tls_a_2_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_tls_a_2
als_a_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_als_a
uav_b_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_uav_b
uav_b_2_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_uav_b_2
voxel_dir=/home/theo/Documents/point_cloud_registration_batch_tests/test_voxels

step_size=0.1
cd $tls_a_2_dir

for filename in *a_2.las; do
    output=${filename:0:12}
    WINEDEBUG=-all wine /APPS/LASTools/bin/lasvoxel -i $filename \
-step $step_size -odir $voxel_dir -o $output"_voxel.las"
done

cd $uav_b_2_dir
for filename in *b_2.las; do
    output=${filename:0:12}
    WINEDEBUG=-all wine /APPS/LASTools/bin/lasvoxel -i $filename \
-step $step_size -odir $voxel_dir -o $output"_voxel.las"
done

# TODOs
# Include step_size in output
# Edit for loop to flag broken inputs

#WINEDEBUG=-all wine /APPS/LASTools/bin/lasvoxel -i /home/theo/Documents/point_cloud_registration_batch_tests/test_uav_b_2/P401_UAV_clip_REGISTERED_2019-09-09_17h21_08_217.las -step 0.1 -odir /home/theo/Documents/point_cloud_registration_batch_tests/test_voxels -o "P401_UAV_clip_voxel.las"
