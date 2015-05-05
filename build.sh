#!/bin/bash
API=android-9
TOOLCHAIN=arm-linux-androideabi-4.9

VERSIONS=v0.12.2
NDK_PATH=~/workspace/android-ndk-r10d
NODE_REPO=~/workspace/node

TOOLCHAIN_PATH=$PWD/out/toolchain

function build_toolchain() {
    rm -rf $TOOLCHAIN_PATH
    mkdir -p $TOOLCHAIN_PATH
    $NDK_PATH/build/tools/make-standalone-toolchain.sh \
	--platform=$API \
	--toolchain=$TOOLCHAIN \
	--arch=arm \
	--install-dir=$TOOLCHAIN_PATH
}

function build_node() {
    BUILD_PATH=out/node/$1
    rm -rf $BUILD_PATH
    mkdir -p $BUILD_PATH
    pushd out/node
    git clone $NODE_REPO $1
    cd $1
    export PATH=$TOOLCHAIN_PATH/bin:$PATH
    export AR=arm-linux-androideabi-ar
    export CC=arm-linux-androideabi-gcc
    export CXX=arm-linux-androideabi-g++
    export LINK=arm-linux-androideabi-g++
    ./configure \
	--without-snapshot \
	--dest-cpu=arm \
	--dest-os=android
    make -j16
    popd
}

function copy_prebuilt() {
    cp out/node/$1/out/Release/node prebuilt/node-$1
}

build_toolchain

for version in $VERSIONS; do
    build_node $version
    copy_prebuilt $version
done
