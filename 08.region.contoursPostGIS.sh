#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions

gdal_contour="tools/gdal_contour_smooth"

work_dir="${main_dir}/work/${country}/${district}/${region}"
style="${main_dir}/templates/contours.style"
template="${main_dir}/templates/contours_empty.pbf"

echo -n " > [DATABASE]: check exists schema \"${pg_schema_contours}\": "
check_schema=`PGPASSWORD=$pg_pass psql -h $pg_host -U $pg_user -d $pg_db -t -c \
        "SELECT count(schema_name) \
            FROM information_schema.schemata \
            WHERE schema_name = '${pg_schema_contours}';"`

if [ $check_schema -eq 0 ] ; then
    echo -n "not exist, create: "
    PGPASSWORD=$pg_pass psql -h $pg_host -U $pg_user -d $pg_db -t -c "CREATE SCHEMA ${pg_schema_contours} AUTHORIZATION ${pg_user};"
else
    echo "Ok, exist."
fi

echo -n " > [DATABASE]: check exists table (${pg_contours_table_prefix}_line): "
table_exist=`PGPASSWORD=$pg_pass psql -h $pg_host -U $pg_user -d $pg_db -t -c \
    "SELECT count(pgc.relname) \
	FROM pg_class pgc \
	LEFT JOIN pg_namespace pgn ON (pgn.oid = pgc.relnamespace) \
	    WHERE nspname NOT IN ('pg_catalog' ,'information_schema') \
	    AND pgc.relkind <> 'i' \
	    AND nspname !~ '^pg_toast' \
	    AND pgc.relname = '${pg_contours_table_prefix}_line';"`
if [ $table_exist -eq 1 ] ; then
    echo "Ok, exist."
elif [ $table_exist -eq 0 ] ; then
    echo "not exist:"
    PGPASSWORD=$pg_pass osm2pgsql \
	--create \
	--database=${pg_db} \
	--username=${pg_user} \
	--host=${pg_host} \
	--port=${pg_port} \
	--output-pgsql-schema=${pg_schema_contours} \
	--prefix=${pg_contours_table_prefix} \
	--cache 5000 \
	--style $style \
	$template
else
    echo
    echo "Unknown ERROR, stop"
    exit 1
fi

rm -vf ${work_dir}/contours.*
echo -n " > [CONTOURS] create contours ESRI Shapefile: "
$gdal_contour \
    -3d \
    -i $contours_interval \
    -a level \
    -snodata $nodata_tif \
    -smooth_cycles $contours_smooth_cycles \
    -smooth_slide $contours_smooth_slide \
    -look_ahead $contours_look_ahead \
    -min_points $contours_min_points \
    -f "ESRI Shapefile" \
    --config GDAL_CACHEMAX 512 \
    "${work_dir}/resampled.tif" \
    "${work_dir}/contours.shp"

echo -n " > [CONTOURS]: load data to PostGIS DB: "
ogr2ogr \
    -progress \
    -explodecollections \
    -update \
    -append \
    -fieldmap identity \
    -mapFieldType Real=Integer \
    -f PostgreSQL "PG:dbname=${pg_db} host=${pg_host} user=${pg_user} password=${pg_pass}" \
    "${work_dir}/contours.shp" \
    -nln ${pg_schema_contours}.${pg_contours_table_prefix}_line

echo " > [CLEAR]: remove SHP data: "
rm -vf ${work_dir}/contours.*
rm -vf ${work_dir}/contours_unproj.*
rm -vf ${work_dir}/resampled.*

echo "done."
