#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/FABDEM/${country_hgt}"
mkdir -p $work_dir

tmp_file_list="${work_dir}/list"
rm -fv $tmp_file_list

server_url="https://data.bris.ac.uk/datasets/25wfy0f9ukoge2gs7a5mqpq2j7"

file_suffix="FABDEM_V1-0.zip"

for i in $(seq $min_lat $max_lat) ; do
    lat_t=`echo $i | awk '{ split($0, n, ""); print n[1] }'`
    lat_b=$((10 * $lat_t))
    lat_e=$(($lat_b + 10))

    for j in $(seq $min_lon $max_lon) ; do
	lon_t=`echo $j | awk '{ split($0, n, ""); print n[1] }'`
	lon_b=$((10 * $lon_t))
	lon_e=$(($lon_b + 10))
	tile_name="${lat_semisphere}${lat_b}${lon_semisphere}$(printf %03d ${lon_b})-${lat_semisphere}${lat_e}${lon_semisphere}$(printf %03d ${lon_e})"
	file_name="${tile_name}_${file_suffix}"
	echo $file_name >> $tmp_file_list
    done
done

for f in $(cat $tmp_file_list | sort | uniq) ; do
    echo "File $f: "
    wget \
	--mirror \
	--continue \
	--output-document=${work_dir}/${f} \
	"${server_url}/${f}"
    if [ -s ${work_dir}/${f} ] ; then
	echo "done."
    else
	rm -vf ${work_dir}/${f}
	echo "not tile, cleared."
    fi
done

rm -vf $tmp_file_list
