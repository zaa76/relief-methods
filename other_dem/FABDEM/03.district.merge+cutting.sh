#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/${district}"
in_dir="${work_dir}/../dem"

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/

mkdir -p $work_dir

pushd ${in_dir}

if [ "${district_extent}" = "-1" ] ; then
    extent_option=""
else
    extent_option="-ul_lr ${district_extent} "
fi

#source /opt/phyghtmap/bin/activate

rm -vf "${work_dir}/merged.tif"
echo -n " > Merged all GTiff for ${country}/${district}: "
gdal_merge.py \
    -n $nodata_tif \
    -a_nodata $nodata_tif \
    $extent_option \
    -co "NUM_THREADS=${num_threads}" \
    -co "BIGTIFF=YES" \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -o "${work_dir}/merged.tif" \
    *.tif

popd

#deactivate

#echo " > clear filled images: "
#rm -vf ${work_dir}/*.bil
#rm -vf ${work_dir}/*.hdr
#rm -vf ${work_dir}/*.prj
echo "done."