#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/../dem_data/Copernicus-DEM/${copernicus_dataset}/${download_district}"
mkdir -p $work_dir

files_list="files"
downloads_list="downloads"

rm -vf ${work_dir}/${files_list}
rm -vf ${work_dir}/${downloads_list}

server_url="ftps://cdsdata.copernicus.eu:990/DEM-datasets/COP-DEM_GLO-30-DTED/2021_1"
copernicus_user="<user of Copernicus resourse>"
copernicus_password="<password of Copernicus resourse>"

wget \
    --ftps-implicit \
    --no-check-certificate \
    --ftp-user=${copernicus_user} \
    --ftp-password=${copernicus_password} \
    --output-document=${work_dir}/mapping.csv \
    ${server_url}/${copernicus_dataset}/mapping.csv

cat ${work_dir}/mapping.csv  | awk -F ';' {'print $2$3" "$1'} | grep -v LatLong > ${work_dir}/${files_list}

for i in $(seq $min_lat $max_lat) ; do
    for j in $(seq $min_lon $max_lon) ; do
	tile="${lat_semisphere}${i}${lon_semisphere}$(printf %03d ${j})"
	for f in $(cat ${work_dir}/${files_list} | awk {'print $1'}) ; do
	    if [ "${f}" = "${tile}" ] ; then
		file_name=$(cat ${work_dir}/${files_list} | grep $f | awk {'print $2'})
		echo "${file_name}" >> ${work_dir}/${downloads_list}
	    fi
	done
    done
done

for d in $(cat ${work_dir}/${downloads_list} | sort | uniq) ; do
    echo "File $d: "
    wget \
	--ftps-implicit \
	--no-check-certificate \
	--ftp-user=${copernicus_user} \
	--ftp-password=${copernicus_password} \
	--continue \
	--output-document=${work_dir}/${d} \
	"${server_url}/${copernicus_dataset}/${d}"
    if [ -s ${work_dir}/${d} ] ; then
	echo "done."
    else
	rm -vf ${work_dir}/${d}
	echo "not tile, cleared."
    fi
done
####################
#aws s3 cp s3://copernicus-dem-30m/Copernicus_DSM_COG_10_N46_00_E008_00_DEM/Copernicus_DSM_COG_10_N46_00_E008_00_DEM.tif . --no-sign-request
