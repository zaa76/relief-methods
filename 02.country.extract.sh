#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/dem"
in_dir="${main_dir}/../data/dem_data/SRTMGL1/${country}/${country_hgt}"

mkdir -p $work_dir

pushd $in_dir

for i in *.zip; do
    base=`basename ${i}.SRTMGL1.hgt.zip`
    echo " > unzip data for ${i}: "
    unzip $i -d $work_dir
done

popd
