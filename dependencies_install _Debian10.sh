# OS is Debian 10 (Buster) x64

echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/postgresql.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt -y update

apt -y install \
	postgresql-client-12 \
	postgresql-server-dev-12 

systemctl stop postgresql && systemctl disable postgresql

apt -y install \
	libxml2 libxml2-dev \
	python2-dev \
	python3-dev python3-numpy \
	python3-pip python3-virtualenv \
	swig cmake doxygen \
	sqlite3 libsqlite3-0 libsqlite3-dev \
	ccache clang-7 llvm-7-tools \
	libtirpc-dev libtirpc3 \
	libexpat1 libexpat1-dev \
	libjson-c3 libjson-c-dev \
	python-pycryptopp libssl-dev \
	libblas3 libblas-dev \
	libblis2 libblis-dev \
	liblapack3 liblapack-dev \
	libxerces-c3.2 libxerces-c-dev \
	libltdl7 libltdl-dev \
	libqhull7 libqhull-dev \
	libprotobuf17 libprotobuf-dev libprotobuf-c1 libprotobuf-c-dev \
	libcunit1 libcunit1-dev \
	bison libbison-dev \
	libzstd1 libzstd-dev \
	libunistring2 libunistring-dev \
	libidn2-0 libidn2-0-dev \
	libunistring2 libunistring-dev \
	libharfbuzz0b libharfbuzz-dev \
	libmpfr6 libmpfr-dev libmpfrc++-dev \
	libgmp10 libgmp-dev

apt -y install \
	libboost-filesystem1.67 libboost-filesystem1.67-dev \
	libboost-regex1.67 libboost-regex1.67-dev \
	libboost-thread1.67.0 libboost-thread1.67-dev \
	libboost-program-options1.67-dev libboost-program-options1.67.0

apt -y install \
	libwebp6 libwebp-dev \
	libcfitsio7 libcfitsio-dev \
	libpng16-16 libpng-dev libpng++-dev \
	libgif7 libgif-dev \
	libarmadillo9 libarmadillo-dev \
	libnetcdff6 libnetcdff-dev libnetcdf-cxx-legacy-dev libnetcdf-c++4 libnetcdf-c++4-dev \
	libcairo2 libcairo2-dev \
	libopenjp2-7 libopenjp2-7-dev \
	libfreexl1 libfreexl-dev \
	libkmlbase1 libkmlconvenience1 libkmldom1 libkmlengine1 libkml-dev \
	libjbig2dec0 libjbig2dec0-dev libjbig0 libjbig-dev \
	libwmf0.2-7 libwmf-dev \
	fftw2 fftw-dev \
	liblcms2-2 liblcms2-dev \
	librsvg2-2 librsvg2-dev \
	libopenexr23 libopenexr-dev \
	libgl1-mesa-dev freeglut3 freeglut3-dev \
	libtiff5 libtiff5-dev libtiffxx5
	
apt -y install \
	fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted \
	fonts-hanazono \
	ttf-unifont \
	fonts-dejavu-core
	
pip3 install Cython sympy

git clone -b 'releases/CGAL-4.14' https://github.com/CGAL/cgal.git
pushd cgal && mkdir -p build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
make && make install && ldconfig
popd && popd

git clone -b 'v1.3.' https://github.com/Oslandia/SFCGAL.git
pushd SFCGAL && mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
make && make install && ldconfig
popd && popd

git clone https://github.com/mdadams/jasper.git
pushd jasper && mkdir my_build && pushd my_build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
make && make install && ldconfig
popd && popd

wget https://download.osgeo.org/proj/proj-6.3.0.tar.gz
wget https://download.osgeo.org/proj/proj-datumgrid-europe-latest.zip
tar -xzvf proj-6.3.0.tar.gz 
pushd proj-6.3.0 && pushd data
unzip ../../proj-datumgrid-europe-latest.zip 
popd
CPPFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1 ./configure --prefix=/usr
make && make install && ldconfig
popd 

wget http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-1.5.1.tar.gz
tar -xzvf libgeotiff-1.5.1.tar.gz
pushd libgeotiff-1.5.1
./configure --prefix=/usr --enable-incode-epsg --with-jpeg=yes --with-libz=yes
make && make install && ldconfig
popd

git clone https://github.com/makinacorpus/libecw.git
pushd libecw
pushd Source/C/NCSEcw/lcms
cat missing | tr -d '\r' > missing-1
mv -f missing-1 missing
popd
./configure CFLAGS="-O0" CXXFLAGS="-O0" --enable-shared --enable-static --prefix=/usr
make && make install && ldconfig
popd

wget http://download.osgeo.org/geos/geos-3.8.0.tar.bz2
tar -xjvf geos-3.8.0.tar.bz2 
pushd geos-3.8.0
./configure --prefix=/usr \
	--enable-python
make && make install && ldconfig 
popd

wget https://github.com/team-charls/charls/archive/1.1.0.tar.gz
tar -xzvf 1.1.0.tar.gz
pushd charls-1.1.0 && mkdir release && pushd release
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=On ..
make && make install && ldconfig
cp ../src/interface.h /usr/include/CharLS/
popd && popd

wget http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-5.0.0-beta0.tar.gz
tar -xzvf libspatialite-5.0.0-beta0.tar.gz
pushd libspatialite-5.0.0-beta0
CFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure --prefix=/usr
make && make install && ldconfig
popd

wget http://www.gaia-gis.it/gaia-sins/librasterlite2-sources/librasterlite2-1.1.0-beta0.tar.gz
tar -xzvf librasterlite2-1.1.0-beta0.tar.gz
pushd librasterlite2-1.1.0-beta0
./configure --prefix=/usr
make && make install && ldconfig
popd

wget https://github.com/libogdi/ogdi/releases/download/ogdi_4_1_0/ogdi-4.1.0.tar.gz
tar -xzvf ogdi-4.1.0.tar.gz 
pushd ogdi-4.1.0
TOPDIR=`pwd` TARGET=Linux ./configure --prefix=/usr --with-expat --with-zlib
TOPDIR=`pwd` TARGET=Linux make
TOPDIR=`pwd` TARGET=Linux make install
cp -v ogdi.pc /usr/lib/pkgconfig/
ldconfig
popd

wget http://download.osgeo.org/gdal/3.0.3/gdal-3.0.3.tar.gz
tar -xzvf gdal-3.0.3.tar.gz 
pushd gdal-3.0.3
./autogen.sh
CXXFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure \
	--prefix=/usr \
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
	--with-proj=/usr
make -j 4 && make install && ldconfig
popd

# gdal_contour with smoothing patch
wget https://trac.osgeo.org/gdal/raw-attachment/ticket/5848/0001-Contours-smoothing-by-sliding-averaging-algorithm.patch
wget http://download.osgeo.org/gdal/2.0.2/gdal-2.0.2.tar.gz
tar -xzvf gdal-2.0.2.tar.gz
pushd gdal-2.0.2
patch -p2 -i ../0001-Contours-smoothing-by-sliding-averaging-algorithm.patch
./autogen.sh
CXXFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" ./configure \
	--enable-shared=no \
	--enable-static=yes \
	--without-ld-shared \
	--prefix=/usr/local \
	--with-libjson-c=internal
make -j 6	
cp apps/gdal_contour /usr/local/bin/gdal_contour_smooth
popd

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

git clone https://github.com/mapnik/mapnik
pushd mapnik
git checkout v3.0.22
git submodule update --init
PYTHON=python3 ./configure \
	PREFIX=/usr \
	CUSTOM_DEFINES="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" \
	XMLPARSER=libxml2
make PYTHON=python3
make PYTHON=python3 install && ldconfig 
popd

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

curl https://sh.rustup.rs -sSf | sh
ln -s ~/.cargo/bin/cargo -t /usr/local/bin/

 wget https://github.com/jblindsay/whitebox-tools/archive/refs/tags/v2.0.0.tar.gz
 tar -xzvf v2.0.0.tar.gz
 cd whitebox-tools-2.0.0 
 cargo build --release
 cp target/release whitebox_tools /opt/relief_build/tools
 
wget http://www.cs.cf.ac.uk/meshfiltering/index_files/Doc/mdsource.zip
unzip mdsource.zip
cd mdenoise
g++ -Wno-write-strings -o mdenoise mdenoise.cpp triangle.c
cp mdenoise /opt/relief_build/tools
 


