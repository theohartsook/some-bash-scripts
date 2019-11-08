# ALS goes here
INPUT_ALS_1=/home/theo/Documents/als_test_registration/ferguson/ALS/pre_fire
INPUT_ALS_2=/home/theo/Documents/als_test_registration/ferguson/ALS/post_fire

# TLS goes here
INPUT_TLS_1=/home/theo/Documents/als_test_registration/ferguson/raw/pre_fire_tls
INPUT_TLS_2=/home/theo/Documents/als_test_registration/ferguson/raw/post_fire_tls
OUTPUT_TLS_1=/home/theo/Documents/als_test_registration/ferguson/TLS/pre_fire
OUTPUT_TLS_2=/home/theo/Documents/als_test_registration/ferguson/TLS/post_fire

# UAV goes here
#INPUT_UAV_1
INPUT_UAV_2=/home/theo/Documents/als_test_registration/ferguson/raw/post_fire_uav
#OUTPUT_UAV_2
OUTPUT_UAV_2=/home/theo/Documents/als_test_registration/ferguson/UAV/post_fire

TEMP_DIRECTORY=/home/theo/Documents/als_test_registration/ferguson/temp
mkdir -p $TEMP_DIRECTORY

cd $INPUT_TLS_1
mkdir -p "$OUTPUT_TLS_1/"las
mkdir -p "$OUTPUT_TLS_1/"registration_matrix

for filename in *.las; do
    plot_id=${filename:0:4}
    als_ref="$plot_id"_ALS.las
    cloudcompare.CloudCompare -SILENT -C_EXPORT_FMT LAS -O $filename -O "$INPUT_ALS_1"/"$als_ref" -ICP -MIN_ERROR_DIFF 1e-8 -RANDOM_SAMPLING_LIMIT 20000
    mv "$plot_id"*_REGISTERED*.las "$OUTPUT_TLS_1"/las
    mv "$plot_id"*_REGISTRATION*.txt "$OUTPUT_TLS_1"/registration_matrix
done

cd $INPUT_TLS_2
mkdir -p "$OUTPUT_TLS_2/"las
mkdir -p "$OUTPUT_TLS_2/"registration_matrix

for filename in *.las; do
    plot_id=${filename:0:4}
    als_ref="$plot_id"_ALS.las
    cloudcompare.CloudCompare -SILENT -C_EXPORT_FMT LAS -O $filename -O "$INPUT_ALS_2"/"$als_ref" -ICP -MIN_ERROR_DIFF 1e-8 -RANDOM_SAMPLING_LIMIT 20000
    mv "$plot_id"*_REGISTERED*.las "$OUTPUT_TLS_2"/las
    mv "$plot_id"*_REGISTRATION*.txt "$OUTPUT_TLS_2"/registration_matrix
done

cd $INPUT_UAV_2
mkdir -p "$OUTPUT_UAV_2/"las
mkdir -p "$OUTPUT_UAV_2/"registration_matrix
mkdir -p "$TEMP_DIRECTORY"/uav
mkdir -p "$TEMP_DIRECTORY"/tls

for filename in *.las; do
    plot_id=${filename:0:4}
    tls_ref="$plot_id"*REGISTERED*.las
    las2las -i $filename -keep_random_fraction 0.1 -odir $TEMP_DIRECTORY -o "$plot_id"_UAV_downsample_01.las
    las2las -i "$OUTPUT_TLS_2"/$tls_ref -keep_random_fraction 0.1 -odir $TEMP_DIRECTORY -o "$plot_id"_TLS_downsample_01.las
done

cd "$TEMP_DIRECTORY"/uav
for filename in *.las; do
    plot_id=${filename:0:4}
    tls_ref="$plot_id"_TLS_downsample_01.las
    cloudcompare.CloudCompare -SILENT -C_EXPORT_FMT LAS -O $filename -O "$INPUT_DIRECTORY"/"$tls_ref" -ICP -MIN_ERROR_DIFF 1e-8 -RANDOM_SAMPLING_LIMIT 60000
    mv "$plot_id"*_REGISTRATION*.txt "$OUTPUT_UAV_2"/registration_matrix
done

cd $INPUT_UAV_2
for filename in *.las; do
    plot_id=${filename:0:4}
    matrix="$plot_id"*_REGISTRATION*.txt
    cloudcompare.CloudCompare -SILENT -APPLY_TRANS "$OUTPUT_UAV_2"/registration_matrix/"$matrix"
    mv "$plot_id"*_REGISTERED*.las "$OUTPUT_UAV_2"/las
done
