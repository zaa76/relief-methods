#!/bin/bash

user="<user EarthExplorer>"
password="<password EarthExplorer>"

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/../data/dem_data/SRTMGL1/${country}/${country_hgt}"
mkdir -p $work_dir

server_url="https://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11"
#server_url="https://step.esa.int/auxdata/dem/SRTMGL1"

file_suffix="SRTMGL1.hgt.zip"

for i in $(seq $hgt_min_lat $hgt_max_lat) ; do
    for j in $(seq $hgt_min_lon $hgt_max_lon) ; do
	tile=${hgt_lat_semisphere}${i}${hgt_lon_semisphere}$(printf %03d ${j})
	file_name=${tile}.${file_suffix}
	echo -n " $tile ... "

	wget \
	    --mirror \
	    --continue \
	    --quiet \
	    --user=${user} --password=${password} \
	    --output-document=${work_dir}/${file_name} \
	    "${server_url}/${file_name}"

	if [ -s ${work_dir}/${file_name} ] ; then
	    echo "done."
	else
	    rm -f ${work_dir}/${file_name}
	    echo "not tile, cleared."
	fi
    done
done
