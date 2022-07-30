#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/${district}/${region}"
out_dir="${main_dir}/work/out"

sloperamp="${main_dir}/ramps/shade.slope.cpt"

#---- Functions -----------------------------------
function gen_relief() {
    local _az=$1
    rm -vf "${work_dir}/hillshade.az.${_az}.tif"
    echo -n " > [Hillshade]: Azimuth: ${_az}: "
    gdaldem hillshade \
	-of GTiff \
	-az ${_az} \
	-igor \
	-compute_edges \
	-z ${hillshade_zfactor} \
	-co "COMPRESS=LZW" \
	-co "PREDICTOR=2" \
	-co "NUM_THREADS=${num_threads}" \
	-co "BIGTIFF=YES" \
	"${work_dir}/resampled.tif" \
	"${work_dir}/hillshade.az.${_az}.tif"
}

function gen_band() {
    local _band=$1
    if [ "${_band}" = "R" ] ; then
	local _cor1="0x20"
	local _cor2="0xFF"
    elif [ "${_band}" = "G" ] ; then
	local _cor1="0x30"
	local _cor2="0xEE"
    elif [ "${_band}" = "B" ] ; then
	local _cor1="0x60"
	local _cor2="0x00"
    fi
    rm -vf shade.band.${_band}.tif
    echo " > [Color Band]: Band ${_band}: ..."
    gdal_calc.py \
	--co="BIGTIFF=YES" \
	--co="COMPRESS=LZW" \
	--co="PREDICTOR=2" \
	--co="NUM_THREADS=${num_threads}" \
	-A "${work_dir}/hillshade.az.${hillshade_azimuth_R}.tif" \
	-B "${work_dir}/hillshade.az.${hillshade_azimuth_G}.tif" \
	-C "${work_dir}/hillshade.az.${hillshade_azimuth_B}.tif" \
	-D "${work_dir}/slopeshade.tif" \
	--outfile="${work_dir}/shade.band.${_band}.tif" \
	--calc="1.0 * (\
	    ( \
		(0.5 * (255 - A)) * ${_cor1} \
		+ (0.5 * (255 - B)) * ${_cor2} \
		+ (0.5 * (255 - C)) * 0x00 \
		+ (0.5 * (255 - D)) * 0x00 \
	    ) / (0.01 \
		+ (0.5 * (255 - A)) \
		+ (0.5 * (255 - B)) \
		+ (0.5 * (255 - C)) \
		+ (0.5 * (255 - D)) \
		) - 128.0 \
	    ) +128.0 + 0.0"
    echo "... done."
}
#---------------------------------------------------------------------------------------

gen_relief ${hillshade_azimuth_R}
gen_relief ${hillshade_azimuth_G}
gen_relief ${hillshade_azimuth_B}

rm -vf "${work_dir}/slope.tif"
echo -n " > [Slope for SlopeShade]: "
gdaldem slope \
    -of GTiff \
    -co "BIGTIFF=YES" \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -co "NUM_THREADS=${num_threads}" \
    -p \
    "${work_dir}/resampled.tif" \
    "${work_dir}/slope.tif"

rm -vf "${work_dir}/slopeshade.tif"
echo -n " > [SlopeShade]: "
gdaldem color-relief \
    -of GTiff \
    -co "BIGTIFF=YES" \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -co "NUM_THREADS=${num_threads}" \
    "${work_dir}/slope.tif" \
    $sloperamp \
    "${work_dir}/slopeshade.tif"

gen_band "R"
gen_band "G"
gen_band "B"

rm -vf "${work_dir}/shade.band.Alpha.tif"
echo " > [Alpha band]: ..."
gdal_calc.py \
    --co="BIGTIFF=YES" \
    --co="COMPRESS=LZW" \
    --co="PREDICTOR=2" \
    --co="NUM_THREADS=${num_threads}" \
    -A "${work_dir}/hillshade.az.${hillshade_azimuth_R}.tif" \
    -B "${work_dir}/hillshade.az.${hillshade_azimuth_G}.tif" \
    -C "${work_dir}/hillshade.az.${hillshade_azimuth_B}.tif" \
    -D "${work_dir}/slopeshade.tif" \
    --outfile="${work_dir}/shade.band.Alpha.tif" \
    --calc="255.0 - 255.0 \
	* ((1.0 - (0.5 * (255 - A)) / 255.0) \
	* (1.0 - (0.5 * (255 - B)) / 255.0) \
	* (1.0 - (0.5 * (255 - C)) / 255.0) \
	* (1.0 - (0.5 * (255 - D)) / 255.0))"
echo "... done."

rm -vf "${work_dir}/shade.stack.vrt"
echo " > [VRT for Combined raster]: "
gdalbuildvrt \
    -separate \
    "${work_dir}/shade.stack.vrt" \
    "${work_dir}/shade.band.R.tif" \
    "${work_dir}/shade.band.G.tif" \
    "${work_dir}/shade.band.B.tif" \
    "${work_dir}/shade.band.Alpha.tif"

echo -n " > [Combined raster assign color order]: "
gdal_edit.py \
    -colorinterp_1 red \
    -colorinterp_2 green \
    -colorinterp_3 blue \
    -colorinterp_4 alpha \
    "${work_dir}/shade.stack.vrt"
echo "... done."

rm -vf $out_file
echo " > [Shaded relief combined raster]: "
gdal_translate \
    -colorinterp red,green,blue,alpha \
    -r cubicspline \
    -of GTiff \
    -co "COMPRESS=ZSTD" \
    -co "ZSTD_LEVEL=9" \
    -co "PREDICTOR=1" \
    -co "NUM_THREADS=${num_threads}" \
    "${work_dir}/shade.stack.vrt" \
    "${out_dir}/shade/${country}_${region}.shade.tif"


echo " > [Clean]: "
rm -vf ${work_dir}/hillshade.*
rm -vf ${work_dir}/shade.band.*
rm -vf ${work_dir}/shade.stack.vrt
rm -vf ${work_dir}/slope*

echo "done."
