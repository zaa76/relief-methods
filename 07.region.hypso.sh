#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

work_dir="${main_dir}/work/${country}/${district}/${region}"
out_dir="${main_dir}/work/out/hypso"

hypsoramp="${main_dir}/ramps/hypso.alpha.cpt"
sloperamp="${main_dir}/ramps/hypso.slope.nodata.noblack.cpt"
shaderamp="${main_dir}/ramps/hypso.shade.combined.alpha.cpt"

#--------------------------------
rm -fv "${work_dir}/slope.tif"
echo -n " > [Slope for SlopeShade]: "
gdaldem slope \
    -of GTiff \
    -compute_edges \
    -b 1 \
    -s 1.0 \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -co "NUM_THREADS=${num_threads}" \
    -co "BIGTIFF=YES" \
    "${work_dir}/resampled.tif" \
    "${work_dir}/slope.tif"

rm -fv "${work_dir}/slopeshade.tif"
echo -n " > [SlopeShade]: "
gdaldem color-relief \
    -of GTiff \
    -alpha \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -co "NUM_THREADS=${num_threads}" \
    -co "BIGTIFF=YES" \
    "${work_dir}/slope.tif" \
    "${sloperamp}" \
    "${work_dir}/slopeshade.tif"

rm -fv "${work_dir}/hillshade.tif"
echo -n " > [Hillshade]: "
gdaldem hillshade \
    -of GTiff \
    -combined \
    -compute_edges \
    -b 1 \
    -z ${hypso_relief_hillshade_zfactor} \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -co "NUM_THREADS=${num_threads}" \
    -co "BIGTIFF=YES" \
    "${work_dir}/resampled.tif" \
    "${work_dir}/hillshade.tif"

rm -fv "${work_dir}/slopeshade.combined.tif"
echo " > [Calculate Combined Shade]: "
gdal_calc.py \
    -A "${work_dir}/slopeshade.tif" \
    --A_band=4 \
    -B "${work_dir}/hillshade.tif" \
    --B_band=1 \
    -C "${work_dir}/slopeshade.tif" \
    --C_band=1 \
    --outfile="${work_dir}/slopeshade.combined.tif" \
    --calc="round_(((1 - A / 255.0) * B + (A / 255.0) * 0.5 * C), 0)" \
    --NoDataValue="${hypso_relief_nodata}" \
    --type=Byte \
    --creation-option="COMPRESS=LZW" \
    --creation-option="PREDICTOR=2" \
    --creation-option="NUM_THREADS=${num_threads}" \
    --creation-option="BIGTIFF=YES"
echo "done."

rm -fv "${work_dir}/shade.tif"
echo -n " > [Transparency Shade]: GTiff(Alpha): "
gdaldem color-relief \
    -of GTiff \
    -alpha \
    -co "COMPRESS=LZW" \
    -co "PREDICTOR=2" \
    -co "NUM_THREADS=${num_threads}" \
    -co "BIGTIFF=YES" \
    "${work_dir}/slopeshade.combined.tif" \
    $shaderamp \
    "${work_dir}/shade.tif"

rm -fv "${work_dir}/shade.png"
echo -n " > [Shade GTiff -> PNG]: (NoData \"${hypso_relief_nodata} ${hypso_relief_nodata} ${hypso_relief_nodata}\"): "
gdal_translate \
    -of PNG \
    -a_nodata "${hypso_relief_nodata} ${hypso_relief_nodata} ${hypso_relief_nodata}" \
    "${work_dir}/shade.tif" \
    "${work_dir}/shade.png"

rm -fv "${work_dir}/hypsometric.png"
rm -fv "${work_dir}/hypsometric.wld"
echo -n " > [Color Image]: (PNG + Wordfile): "
gdaldem color-relief \
    -of PNG \
    -co "WORLDFILE=YES" \
    "${work_dir}/resampled.tif" \
    "${hypsoramp}" \
    "${work_dir}/hypsometric.png"

rm -fv "${work_dir}/hypso.wld"
echo -n " > [Create WLD]: "
cp -v "${work_dir}/hypsometric.wld" "${work_dir}/hypso.wld"

rm -fv "${work_dir}/hypso.png"
echo " > [Composite Relief]: (hypsometric + shade): "

    # *** ImageMagick ENV options ***
    # MAGICK_MAP_LIMIT="${memory}MiB"
    # MAGICK_WIDTH_LIMIT="32MiP"
    # MAGICK_HEIGHT_LIMIT="32iMP"
    # MAGICK_DISK_LIMIT="50GiB"
    # MAGICK_AREA_LIMIT="40GiP"
    # MAGICK_THREAD_LIMIT=${num_threads}
    # MAGICK_MEMORY_LIMIT="${memory_magick}"

convert \
    -monitor -define registry:temporary-path="${work_dir}" \
    \( -monitor "${work_dir}/hypsometric.png" -define png:color-type=2 +level 50%,100% \) \
    \( -monitor "${work_dir}/shade.png" -define png:color-type=2 \) \
    -compose dissolve -define compose:args='50,50' -composite \
    "${work_dir}/hypso.png"

echo "done."

mkdir -p "${out_dir}"
rm -fv "${out_dir}/${country}_${region}.hypso.tif"
echo -n " > [PNG -> GTiff]: (Alpha + NoData: \"${hypso_relief_nodata} ${hypso_relief_nodata} ${hypso_relief_nodata}\"): "

    # *** Tiled options ***
    # -co "BLOCKXSIZE=64" -co "BLOCKYSIZE=64" -co "TILED=YES"

gdalwarp \
    -of GTiff \
    -srcnodata "${hypso_relief_nodata} ${hypso_relief_nodata} ${hypso_relief_nodata}" \
    -dstnodata 0 \
    -t_srs "EPSG:3857" \
    -co "COMPRESS=ZSTD" \
    -co "ZSTD_LEVEL=9" \
    -co "PREDICTOR=1" \
    -co "NUM_THREADS=${num_threads}" \
    -wm $memory_gdal \
    -co "BIGTIFF=YES" \
    "${work_dir}/hypso.png" \
    "${out_dir}/${country}_${region}.hypso.tif"

echo " > [CLEAR]: "
rm -vf ${work_dir}/hypso*
rm -vf ${work_dir}/*shade*
rm -vf ${work_dir}/slope*

echo "done."
