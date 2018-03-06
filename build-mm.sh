#!/usr/bin/env sh
set -e

# Script used to build MM from source (on Linux/Ubuntu)

# Dependencies (ubuntu / debian)
# sudo apt-get install subversion build-essential autoconf automake libtool libboost-dev \
#                      pkg-config zlib1g-dev swig ant python-dev python-numpy-dev


ROOT_DIR=$(pwd)
IJ_DIR="$ROOT_DIR/Fiji.app"
MM_DIR="$ROOT_DIR/micro-manager"

if [ ! -f "fiji-linux64.zip" ]; then
    echo "Downloading Fiji."
    wget "https://downloads.imagej.net/fiji/latest/fiji-linux64.zip"
fi

#rm -fr "$IJ_DIR"
if [ ! -d "$IJ_DIR" ]; then
    unzip "fiji-linux64.zip"
fi

mkdir -p "3rdpartypublic/classext"
if [ ! -f "3rdpartypublic/classext/iconloader.jar" ]; then
    wget -P "3rdpartypublic/classext" "https://valelab4.ucsf.edu/svn/3rdpartypublic/classext/iconloader.jar"
fi

if [ ! -f "3rdpartypublic/classext/TSFProto.jar" ]; then
    wget -P "3rdpartypublic/classext" "https://valelab4.ucsf.edu/svn/3rdpartypublic/classext/TSFProto.jar"
fi

if [ ! -d "$MM_DIR" ]; then
  git clone https://github.com/micro-manager/micro-manager.git
fi

cd "$MM_DIR"
GIT_HASH=$(git rev-parse --short HEAD)

./autogen.sh
./configure --enable-imagej-plugin="$IJ_DIR" \
            --with-ij-jar="$IJ_DIR/jars/ij-1.51v-SNAPSHOT.jar" \
            JAVA_HOME="/usr/lib/jvm/default-java/" CC="gcc" CXX="g++"

make fetchdeps
make

make install
cp "$MM_DIR/bindist/any-platform/MMConfig_demo.cfg" "$IJ_DIR"

cd ../

# Generate zip bundle
mkdir -p "bundles/"
BUNDLE_NAME="$(date +"%Y.%m.%d.%H.%M").MicroManager-$GIT_HASH.zip"
zip -r "bundles/$BUNDLE_NAME" "$IJ_DIR"