#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/dem"
in_dir="${main_dir}/../dem_data/Copernicus-DEM/${copernicus_dataset}"

mkdir -p $work_dir
rm -vf ${work_dir}/*

pushd $work_dir

for a in $(ls -1 ${in_dir} | grep tar) ; do
    echo -n "${a}: "
    tar --wildcards --exclude='*/*/' --strip=2 -xf ${in_dir}/${a} '*.dt2'
    echo "done."
done

popd
