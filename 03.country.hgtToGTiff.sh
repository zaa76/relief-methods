#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

wbt="${main_dir}/tools/whitebox_tools"

work_dir="${main_dir}/work/${country}/dem"

mkdir -p $work_dir

# ---- Functions ----------------------------------------------------------
function fixingSRTM() {
    local _base=$1
    local _dir=$2

    echo -n " > [Fixing 3601x3601 SRTM]: ${_base} ... "

    local _latitude=`echo ${_base}  | cut -b2-3`
    local _longitude=`echo ${_base} | cut -b5-7`
    local _semisphere_x=`echo $base | cut -b1`
    if [ "${_semisphere_x}" = "S" ] ; then
	local _latitude=`echo ${_latitude} | awk '{printf "%.10f", $1 * -1 }'`
    fi
    local _semisphere_y=`echo ${_base} | cut -b4`
    if [ "${_semisphere_y}" = "W" ] ; then
	local _longitude=`echo ${_longitude} | awk '{printf "%.10f", $1 * -1 }'`
    fi
    local _x=`echo ${_longitude} | awk '{printf "%.0f", $1}'`
    local _y=`echo ${_latitude}  | awk '{printf "%.0f", $1}'`

    gdalwarp \
	-of GTiff \
	-multi \
	-r ${resample_method} \
	-te $((${_x}-1)).99986111 $((${_y}-1)).99986111 $((${_x}+1)).00013889 $((${_y}+1)).00013889 \
	-tr 0.000277777777778 -0.000277777777778 \
	"${_dir}/${_base}.hgt" \
	"${_dir}/${_base}.fix.tif"

    echo " > [CLEAR]: "
    rm -vf "${_dir}/${_base}.hgt"
}

function fillingVoids() {
    local _base=$1
    local _dir=$2

    echo -n " > [Fill all voids]: ${_base}: "
    gdal_fillnodata.py \
	-of GTiff \
	"${_dir}/${_base}.fix.tif" \
	"${_dir}/${_base}.fill.tif"

    echo " > [CLEAR]: "
    rm -vf "${_dir}/${_base}.fix.tif"
}

function smoothing() {
    local _base=$1
    local _dir=$2
    echo -n " > [Smoothing DEM]: ${_base} ... "
    $wbt \
	-r=FeaturePreservingSmoothing \
	--wd="${_dir}" \
	--dem="${_base}.fill.tif" \
	-o="${_base}.tif" \
	--filter=${smooth_filter} \
	--norm_diff=${smooth_norm_diff} \
	--num_iter=${smooth_num_iter} \
	--max_diff=${smooth_max_diff}
    echo "done."

    echo " > [CLEAR]: "
    rm -vf "${_dir}/${_base}.fill.tif"
}

#------------------------------------------------------------------------------------

pushd $work_dir

for i in *.hgt; do
    base=`basename ${i} .hgt`
    fixingSRTM $base $work_dir
    fillingVoids $base $work_dir
    smoothing $base $work_dir
done

popd
