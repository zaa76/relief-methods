


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
