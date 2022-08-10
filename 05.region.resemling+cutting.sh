#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/${district}/${region}"
out_dir="${main_dir}/work/extents"

mkdir -p $out_dir

boundaries="${main_dir}/boundaries/geojson/${country}/${region}.geojson"

# ---- Functions -------------------------------------------------------------
function resampling() {
    local _in_file=$1
    rm -vf "resampled.tif"
    echo -n " > [Lat/Long->Mercator]: Resolution: ${resample_resolution}, cutting by \"${region}\": "
    gdalwarp \
	-of GTiff \
	-wt Float32 \
	-ot Float32 \
	-srcnodata ${nodata_tif} \
	-cutline ${boundaries} \
	-crop_to_cutline \
	-wo "CUTLINE_ALL_TOUCHED=TRUE" \
	-wo "SAMPLE_STEPS=100" \
	-co "COMPRESS=LZW" \
	-co "PREDICTOR=2" \
	-co "BIGTIFF=YES" \
	-co "NUM_THREADS=${num_threads}" \
	-wm $memory_gdal \
	-s_srs "EPSG:${src_epsg}" \
	-t_srs "EPSG:${dst_epsg}" \
	-tr ${resample_resolution} ${resample_resolution} \
	-r ${resample_method} \
	-tap \
	-order 3 \
	-multi \
	"${_in_file}" \
	"resampled.tif"
}

function layer_extent() {
    local _in_file=${work_dir}/resampled.tif
    local _out_file=${out_dir}/${country}_${region}.extent
    EXTENT=$(gdalinfo ${_in_file} |\
    grep "Lower Left\|Upper Right" |\
    sed "s/Lower Left  //g;s/Upper Right //g;s/).*//g" |\
    tr "\n" " " |\
    sed 's/ *$//g' |\
    tr -d "[(,]" |\
    sed 's/[[:space:]]\+/ /g' |\
    sed 's/^ *//' |\
    sed 's/[[:space:]]/ /g')

    echo "$EXTENT" > ${_out_file}
}
#----------------------------------------------------------------

mkdir -p $work_dir
in_file="${work_dir}/../merged.tif"

pushd ${work_dir}

resampling $in_file

echo -n " > [LAYER]: create extent: "
layer_extent
echo "done."

popd
