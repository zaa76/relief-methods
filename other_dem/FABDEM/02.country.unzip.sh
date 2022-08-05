#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/dem"
in_dir="${main_dir}/FABDEM/${country_hgt}"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/

mkdir -p $work_dir
rm -vf ${work_dir}/*

pushd $in_dir

for i in $(seq $min_lat $max_lat) ; do
    for j in $(seq $min_lon $max_lon) ; do
	file_name="${lat_semisphere}${i}${lon_semisphere}$(printf %03d ${j})_FABDEM_V1-0.tif"
	for f in *.zip; do

#echo "> Arc: $f"
	    file_exist=`unzip -l $f | grep $file_name &>/dev/null && echo true || echo false`
	    if [[ "${file_exist}" = "true" ]] ; then

#echo " ---> $file_name"

		echo -n "${file_name}: "
		unzip $f $file_name -d $work_dir &>/dev/null
		echo "done."
		break
#	    else
#		echo "${file_name}: not exist in archive."
#		break
	    fi
	done
    done
done

popd
