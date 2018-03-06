#!/usr/bin/env sh
set -e

# Script used to build MM from source (on Linux/Ubuntu)

# Dependencies (ubuntu / debian)
# sudo apt-get install subversion build-essential autoconf automake libtool libboost-dev pkg-config zlib1g-dev swig ant python-dev python-numpy-dev


CURR_DIR=$(pwd)

if [ ! -f "fiji-linux64.zip" ]; then
    echo "Downloading Fiji."
    wget "https://downloads.imagej.net/fiji/latest/fiji-linux64.zip"
fi

rm -fr Fiji.app/
if [ ! -d "Fiji.app" ]; then
  unzip "fiji-linux64.zip"
fi

if [ ! -f "Fiji.app/MMConfig_demo.cfg" ]; then
  wget "https://raw.githubusercontent.com/micro-manager/micro-manager/master/bindist/any-platform/MMConfig_demo.cfg" -O "Fiji.app/MMConfig_demo.cfg"
fi

if [ ! -d "micro-manager" ]; then
  git clone https://github.com/micro-manager/micro-manager.git
fi

svn checkout "https://valelab4.ucsf.edu/svn/3rdpartypublic/"

cd micro-manager/
GIT_HASH=$(git rev-parse --short HEAD)

# Build MM
./autogen.sh
CC=gcc CXX=g++ ./configure --enable-imagej-plugin="$CURR_DIR/Fiji.app" \
						   --with-ij-jar="$CURR_DIR/Fiji.app/jars/ij-1.51v-SNAPSHOT.jar" \
						   JAVA_HOME="/usr/lib/jvm/default-java/"

make fetchdeps
make

make install

cd ../

# Generate zip bundle
mkdir -p bundles/
BUNDLE_NAME="$(date +"%Y.%m.%d.%H.%M").MicroManager-$GIT_HASH.zip"
zip -r bundles/$BUNDLE_NAME Fiji.app/
