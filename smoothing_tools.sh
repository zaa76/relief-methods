# Pathing GDAL_CONTOUR tool for better smoothing contour lines
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
cp apps/gdal_contour /opt/relief_build/tools/gdal_contour_smooth
popd

# Rust compiler for build WHITEBOX_TOOLS
curl https://sh.rustup.rs -sSf | sh
ln -s ~/.cargo/bin/cargo -t /usr/local/bin/

# whiebox_tools
wget https://github.com/jblindsay/whitebox-tools/archive/refs/tags/v2.0.0.tar.gz
tar -xzvf v2.0.0.tar.gz
cd whitebox-tools-2.0.0 
cargo build --release
cp target/release whitebox_tools /opt/relief_build/tools

# mdenoise
wget http://www.cs.cf.ac.uk/meshfiltering/index_files/Doc/mdsource.zip
unzip mdsource.zip
cd mdenoise
g++ -Wno-write-strings -o mdenoise mdenoise.cpp triangle.c
cp mdenoise /opt/relief_build/tools
