# OS is Debian 11 (bullseye) x64qqqqq


echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/postgresql.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt -y update

apt -y install \
	postgresql-client-12 \
	postgresql-server-dev-12 
  
 systemctl stop postgresql && systemctl disable postgresql
 
 apt -y install \
	libxml2 libxml2-dev \
	python3-dev python3-numpy \
	python3-pip python3-virtualenv \
	python3-argparse-manpage \
	swig cmake doxygen \
	ccache clang-9 llvm-9-tools \
	libidn2-0 libidn2-0-dev	\
	libunistring2 libunistring-dev \
	libharfbuzz0b libharfbuzz-dev \
	libmpfr6 libmpfr-dev libmpfrc++-dev \
	libgmp10 libgmp-dev
	
apt -y install \
	libtirpc-dev libtirpc3 \
	libexpat1 libexpat1-dev \
	libjson-c5 libjson-c-dev libjson11-1 libjson11-1-dev \
	libssl-dev \
	libblas3 libblas-dev \
	libblis3 libblis-dev \
	liblapack3 liblapack-dev \
	libxerces-c3.2 libxerces-c-dev \
	libltdl7 libltdl-dev \
	libqhull8.0 libqhull-dev \
	libprotobuf23 libprotobuf-dev libprotobuf-c1 libprotobuf-c-dev \
	install liblz4-1 liblz4-dev

apt -y install \
	libcunit1 libcunit1-dev \
	libprotoc23 libprotoc-dev \
	bison libbison-dev \
	libzstd1 libzstd-dev \
	libunistring2 libunistring-dev \
	libbz2-1.0 libbz2-dev \
	liblua5.4-0 liblua5.4-dev \
	clang-tidy pandoc \
	libboost-filesystem1.74.0 libboost-filesystem1.74-dev \
	libboost-regex1.74.0 libboost-regex1.74-dev \
	libboost-thread1.74.0 libboost-thread1.74-dev \
	libboost-program-options1.74-dev libboost-program-options1.74.0	\
	protobuf-c-compiler

# Graphics Libraries
apt -y install \
	libwebp6 libwebp-dev \
	libcfitsio9 libcfitsio-dev \
	libpng16-16 libpng-dev libpng++-dev \
	libgif7 libgif-dev \
	libarmadillo10 libarmadillo-dev \
	libnetcdff7 libnetcdff-dev \
	libnetcdf-cxx-legacy-dev libnetcdf-c++4 libnetcdf-c++4-dev \
	libopenjp2-7 libopenjp2-7-dev \
	libfreexl1 libfreexl-dev \
	libkmlbase1 libkmlconvenience1 libkmldom1 libkmlengine1 libkml-dev \
	libjbig2dec0 libjbig2dec0-dev libjbig0 libjbig-dev \
	libwmf0.2-7 libwmf-dev \
	fftw2 fftw-dev \
	liblcms2-2 liblcms2-dev \
	librsvg2-2 librsvg2-dev \
	libopenexr25 libopenexr-dev \
	libgl1-mesa-dev freeglut3 freeglut3-dev \
	libtiff5 libtiff5-dev libtiffxx5
	liblz4-1 liblz4-dev
	
# Fonts	for testing when using TileStache
apt -y install \
	fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted \
	fonts-hanazono \
	ttf-unifont \
	fonts-dejavu-core \
	fonts-noto-extra fonts-noto-cjk-extra fonts-noto-color-emoji
  
 pip3 install Cython sympy
 
 wget https://sqlite.org/2022/sqlite-autoconf-3380500.tar.gz
tar -xzvf sqlite-autoconf-3380500.tar.gz
pushd sqlite-autoconf-3380500

./configure \
	--prefix=/usr/local \
	--disable-static \
	--enable-fts5 \
	CPPFLAGS="-DSQLITE_ENABLE_FTS3=1 \
		-DSQLITE_ENABLE_FTS4=1 \
		-DSQLITE_ENABLE_COLUMN_METADATA=1 \
		-DSQLITE_ENABLE_UNLOCK_NOTIFY=1 \
		-DSQLITE_ENABLE_DBSTAT_VTAB=1 \
		-DSQLITE_SECURE_DELETE=1 \
		-DSQLITE_ENABLE_FTS3_TOKENIZER=1 \
		-DSQLITE_ENABLE_RTREE=1"
make && make install && ldconfig
popd

wget https://github.com/CGAL/cgal/releases/download/releases/CGAL-5.0.2/CGAL-5.0.2.tar.xz
tar -xJvf CGAL-5.0.2.tar.xz
pushd CGAL-5.0.2 && mkdir build && pushd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE="Release" ..
make && make install && ldconfig
popd && popd

wget https://github.com/Oslandia/SFCGAL/archive/refs/tags/v1.3.8.tar.gz -O SFCGAL.tar.gz
tar -xzvf SFCGAL.tar.gz
pushd SFCGAL-1.3.8 && mkdir build && pushd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE="Release" ..
make -j 4 && make install && ldconfig
popd && popd

wget https://github.com/jasper-software/jasper/releases/download/version-3.0.4/jasper-3.0.4.tar.gz
tar -xzvf jasper-3.0.4.tar.gz
pushd jasper-3.0.4 && mkdir my_build && pushd my_build
cmake  -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE="Release" ..
#-DJAS_ENABLE_AUTOMATIC_DEPENDENCIES=false .. 
make && make install && ldconfig
popd && popd

wget http://download.osgeo.org/proj/proj-7.2.1.tar.gz
wget https://download.osgeo.org/proj/proj-datumgrid-europe-latest.zip
wget http://download.osgeo.org/proj/proj-datumgrid-world-latest.zip
tar -xzvf proj-7.2.1.tar.gz 
pushd proj-7.2.1 && pushd data
unzip ../../proj-datumgrid-world-latest.zip
unzip ../../proj-datumgrid-europe-latest.zip
popd
CPPFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1 ./configure \
	--prefix=/usr/local
make && make install && ldconfig
popd 

wget http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-1.7.1.tar.gz
tar -xzvf libgeotiff-1.7.1.tar.gz
pushd libgeotiff-1.7.1
./autogen.sh
CPPFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure \
	--prefix=/usr/local \
	--with-jpeg=yes \
	--with-libz=yes \
	--with-zlib=yes \
	--with-zip=yes
make -j 4 && make install && ldconfig
popd

git clone https://github.com/forostm/libecw.git
pushd libecw
./bootstrap
./configure CFLAGS="-O0" CXXFLAGS="-O0" --enable-shared --enable-static --prefix=/usr/local
make && make install && ldconfig
popd

wget https://github.com/team-charls/charls/archive/refs/tags/2.3.4.tar.gz -O charls.tar.gz
tar -xzvf charls.tar.gz
pushd charls-2.3.4 && mkdir build && pushd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=On ..
make -j 2 && make install && ldconfig
#cp ../src/interface.h /usr/local/include/charls/
popd && popd

git clone https://github.com/CGX-GROUP/librttopo.git
pushd librttopo
./autogen.sh
./configure --prefix=/usr/local
make -j 2 && make install && ldconfig
popd

wget http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-5.0.1.tar.gz
tar -xzvf libspatialite-5.0.1.tar.gz
pushd libspatialite-5.0.1
CFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure --prefix=/usr/local
make -j 4 && make install && ldconfig
popd

wget http://www.gaia-gis.it/gaia-sins/librasterlite2-sources/librasterlite2-1.1.0-beta1.tar.gz
tar -xzvf librasterlite2-1.1.0-beta1.tar.gz
pushd librasterlite2-1.1.0-beta1
CPPFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure --prefix=/usr/local
make -j 2 && make install && ldconfig
popd

wget https://github.com/libogdi/ogdi/releases/download/ogdi_4_1_0/ogdi-4.1.0.tar.gz
tar -xzvf ogdi-4.1.0.tar.gz 
pushd ogdi-4.1.0
#patch -p1 -i ../ogdi-patch/ogdi-format.patch 
TOPDIR=`pwd` TARGET=Linux ./configure --prefix=/usr/local --with-expat --with-zlib
TOPDIR=`pwd` TARGET=Linux make
TOPDIR=`pwd` TARGET=Linux make install
cp -v ogdi.pc /usr/local/lib/pkgconfig/
ldconfig
popd

wget https://github.com/OSGeo/gdal/releases/download/v3.5.0/gdal-3.5.0.tar.gz
tar -xzvf gdal-3.5.0.tar.gz 
pushd gdal-3.5.0
./autogen.sh
CXXFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure \
	--prefix=/usr/local \
	--with-pg=yes \
	--with-rasterlite2=yes \
	--with-jpeg12=yes \
	--with-liblzma=yes \
	--with-freexl=yes \
	--with-ogdi=yes \
	--with-spatialite=yes \
	--with-webp=yes \
	--with-python=yes \
	--with-jpeg=yes \
	--with-poppler=yes \
	--with-sfcgal=yes \
	--with-armadillo=yes \
	--with-ecw=yes \
	--with-qhull=yes \
	--with-cfitsio=yes \
	--with-proj=/usr/local \
	--with-zstd=yes
make -j 6 && make install && ldconfig
popd

pip3 install --global-option=build_ext --global-option="-I/usr/local/include" GDAL==`gdal-config --version`

git clone https://github.com/openstreetmap/osm2pgsql.git
pushd osm2pgsql && mkdir build && pushd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_FLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ..
make -j 2 && make install && ldconfig
popd && popd

wget http://www.imagemagick.org/download/ImageMagick.tar.bz2
tar -xjvf ImageMagick.tar.bz2
cd ImageMagick*
./configure \
	--prefix=/usr \
	--with-modules=yes \
	--with-wmf=yes \
	--with-rsvg=yes \
	--with-openjp2=yes \
	--with-gslib=yes
make -j 4 && make install && ldconfig && cd ..

wget https://github.com/postgis/postgis/archive/refs/tags/3.2.1.tar.gz -O postgis.tar.gz
tar -xzvf postgis.tar.gz
pushd postgis-3.2.1
./autogen.sh
./configure \
	--prefix=/usr/local \
	--with-raster-dblwarning
	--enable-shared=no --enable-static=yes
make -j 4 && make && make install
popd

wget https://github.com/mapnik/mapnik/releases/download/v3.1.0/mapnik-v3.1.0.tar.bz2
tar -xjvf mapnik-v3.1.0.tar.bz2
pushd mapnik-v3.1.0
PYTHON=python3 ./configure \
	PREFIX=/usr/local \
	CUSTOM_CXXFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" \
	XMLPARSER=libxml2
make PYTHON=python3
make PYTHON=python3 install && ldconfig 
popd




 
