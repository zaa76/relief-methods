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

#Europe/Ukraine
#Europe/Belarus
#Europe/Moldova
#Asia/Russian_Federation
#wget --ftp-user=zimasanya --ftp-password=P@ssw0rd --ftps-implicit --no-check-certificate ftps://cdsdata.copernicus.eu:990/DEM-datasets/COP-DEM_GLO-30-DTED/2021_1/Europe/Ukraine/mapping.csv
#cdsdata.copernicus.eu:990/DEM-datasets/COP-DEM_GLO-30-DTED/2021_1/Europe/Ukraine/DEM1_SAR_DTE_30_20110117T151606_20130508T150845_ADS_000000_6tTc.DEM.tar

server_url="ftps://cdsdata.copernicus.eu:990/DEM-datasets/COP-DEM_GLO-30-DTED/2021_1"
copernicus_user="zimasanya"
copernicus_password="P@ssw0rd"

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

#rm -vf $tmp_file_list

#aws s3 cp s3://copernicus-dem-30m/Copernicus_DSM_COG_10_N46_00_E008_00_DEM/Copernicus_DSM_COG_10_N46_00_E008_00_DEM.tif . --no-sign-request
