#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/${district}"
in_dir="${main_dir}/work/${country}/dem"

mkdir -p $work_dir

pushd ${in_dir}

echo -n " > [Merged all GTiff]: ${country}/${district}: "
rm -vf "${work_dir}/merged.tif"
gdal_merge.py \
    -n $nodata_tif \
    -ul_lr ${district_extent} \
    -co "NUM_THREADS=${num_threads}" \
    -co "BIGTIFF=YES" \
    -co "TILED=YES" \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -o "${work_dir}/merged.tif" \
    *.tif

popd

echo "done."
