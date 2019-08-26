filtervalue=-4 # -4 and -7 are both good choices.
suffix="_reflectance_filter_$filtervalue.las"
cd /home/theo/Documents/tls_test
# Loop through each file name with the extension .las in the current directory:
for filename in *.las; do
	echo "Processing "$filename
	# Strip the .las from the filename:
	basename=`basename $filename .las`
	# Define the output filename as the basename + suffix:
	filtername=$basename$suffix
	# Run las2las on each input file and output with a new label:
	WINEDEBUG=-all wine /APPS/LASTools/bin/las2las -i $filename -o $filtername \
    -cpu64 -keep_attribute_above 1 $filtervalue
done

