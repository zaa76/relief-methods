#!/bin/bash

main_dir=$(pwd)

. ${main_dir}/config
. ${main_dir}/regions_pg

work_dir="${main_dir}/work/${country}/${district}/${region}"
in_dir="${main_dir}/work/out"
out_dir="${main_dir}/work/out/sql"

mkdir -p $out_dir

#---- Functions --------------------------------------------------------------------
function check_schema() {
    local _schema_name=$1
    echo -n " > [Check exists DB Schema]: \"${_schema_name}\": "
    local _schema_exist=`PGPASSWORD=$pg_pass $psql -h $pg_host -U $pg_user -d $pg_db -t -c \
        "SELECT count(schema_name) \
            FROM information_schema.schemata \
            WHERE schema_name = '${_schema_name}';"`
    if [ ${_schema_exist} -eq 0 ] ; then
	echo -n "not exist, create: "
	PGPASSWORD=$pg_pass $psql -h $pg_host -U $pg_user -d $pg_db -t -c \
	    "CREATE SCHEMA ${_schema_name} AUTHORIZATION ${pg_user};"
    else
	echo "Ok."
    fi
}

function delete_table() {
    local _table_name=$1
    local _schema_name=$2
    echo -n " > [Check exists Table]: \"${_schema_name}.${_table_name}\": "
    local _table_exist=`PGPASSWORD=$pg_pass $psql -h $pg_host -U $pg_user -d $pg_db -t -A -c \
        "SELECT count(pgc.relname) \
            FROM pg_class pgc \
            LEFT JOIN pg_namespace pgn ON (pgn.oid = pgc.relnamespace) \
            WHERE nspname NOT IN ('pg_catalog' ,'information_schema') \
            AND pgc.relkind <> 'i' \
            AND nspname !~ '^pg_toast' \
            AND pgc.relname = '${_table_name}';"`

    if [ ${_table_exist} -gt 0 ] ; then
        echo -n "exist, delete: "
        PGPASSWORD=$pg_pass $psql -h $pg_host -U $pg_user -d $pg_db -t -A -c \
            "DROP TABLE ${_schema_name}.${_table_name};"
    else
        echo "Ok."
    fi
}

function create_sql() {
    local _relief_type=$1
    local _tile=$2
    local _tif="${in_dir}/${_relief_type}/${_tile}.${_relief_type}.tif"
    local _sql="${out_dir}/${_tile}.${_relief_type}.sql"
    if [ "${_relief_type}" = "shade" ] ; then
	local _schema=$pg_schema_shade
	if [ "${pg_shade_overview}" = "0" ] ; then
	    local _options=" "
	else
	    local _options="-l ${pg_shade_overview} "
	fi
    elif [ "${_relief_type}" = "hypso" ] ; then
	local _schema=$pg_schema_hypso
	if [ "${pg_hypso_overview}" = "0" ] ; then
	    local _options=" "
	else
	    local _options="-l  ${pg_hypso_overview} "
	fi
    fi
    echo -n " > [Generate SQL]: \"${_relief_type}\": "
    $raster2pgsql \
	${_tif} \
	-c -C -r -I -Y -M \
	${_options} \
	-t ${pg_tile_size}x${pg_tile_size} \
	-s $dst_epsg \
	${_schema}.${_tile} \
	> ${_sql}
    echo "done."
}

function loadToDB() {
    local _relief_type=$1
    local _tile=$2
    local _sql="${out_dir}/${_tile}.${_relief_type}.sql"
    echo " > [Loading to PostGIS]: \"${_relief_type}\": "
    PGPASSWORD=$pg_pass $psql -h $pg_host -U $pg_user -d $pg_db -t -f ${_sql}
    echo "done."
}

#-------------------------------------------------------------------------------------

tile_name="${country}_${region}"

check_schema shade
check_schema hypso

if [ "${pg_shade_overview}" = "0" ] ; then
    delete_table $tile_name $pg_schema_shade
else
    overview_shade=`echo ${pg_shade_overview} | sed 's/,/ /g'`
    for ts in $overview_shade ; do
	delete_table o_${ts}_${tile_name} $pg_schema_shade
    done
    delete_table $tile_name $pg_schema_shade
fi

if [ "${pg_hypso_overview}" = "0" ] ; then
    delete_table $tile_name $pg_schema_hypso
else
    overview_hypso=`echo ${pg_hypso_overview} | sed 's/,/ /g'`
    for th in $overview_hypso ; do
	delete_table o_${th}_${tile_name} $pg_schema_hypso
    done
    delete_table $tile_name $pg_schema_hypso
fi

create_sql shade $tile_name
create_sql hypso $tile_name

loadToDB shade $tile_name
loadToDB hypso $tile_name

echo " > [CLEAR]: "
rm -fv ${out_dir}/${tile_name}.*.sql

echo "done."
