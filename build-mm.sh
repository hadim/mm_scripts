#!/usr/bin/env sh
set -e

# Script used to build MM from source (on Linux/Ubuntu)

# Dependencies (ubuntu / debian)
# sudo apt-get install subversion build-essential autoconf automake libtool pkg-config libboost1.54-all-dev zlib1g-dev swig openjdk-7-jdk ant python-dev python-numpy-dev


CURR_DIR=$(pwd)

if [ ! -f "ij149.zip" ]; then
    echo "Please download ij149.zip with wget http://rsb.info.nih.gov/ij/download/zips/ij149.zip"
    exit 1
fi

rm -fr ImageJ/
if [ ! -d "ImageJ" ]; then
  unzip ij*.zip
fi

if [ ! -f "ImageJ/MMConfig_demo.cfg" ]; then
  wget https://raw.githubusercontent.com/micro-manager/micro-manager/master/bindist/any-platform/MMConfig_demo.cfg -O ImageJ/MMConfig_demo.cfg
fi

if [ ! -d "micro-manager" ]; then
  git clone https://github.com/micro-manager/micro-manager.git
fi

cd micro-manager/
GIT_HASH=$(git rev-parse --short HEAD)

# Build MM
./autogen.sh
CC=gcc CXX=g++ ./configure --enable-imagej-plugin=$CURR_DIR/ImageJ JAVA_HOME=/usr/lib/jvm/default-java/
make fetchdeps
make

make install

cd ../

# Generate zip bundle
mkdir -p bundles/
BUNDLE_NAME="$(date +"%Y.%m.%d.%H.%M").MicroManager-$GIT_HASH.zip"
zip -r bundles/$BUNDLE_NAME ImageJ/
