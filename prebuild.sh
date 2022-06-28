#!/bin/sh

set -e

export WORKDIR="${ROOT}/prebuild"
export ARIANG_DIR="${ROOT}/www"

export ARIANG_VERSION="1.2.4"

rm -rf ${WORKDIR}
mkdir ${WORKDIR}
cd ${WORKDIR}

echo "Building aria2"

git clone https://github.com/aria2/aria2 -b release-1.36.0 --depth=1
cd aria2
autoreconf -i
PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig  ./configure --host $ARCH_TRIPLET CPPFLAGS="-fsanitize=address" LDFLAGS="-fsanitize=address" --prefix="${INSTALL_DIR}"
make -j$(nproc --all)
make install

echo "Installing AriaNg"

cd ${WORKDIR}
wget "https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip"
rm -rf ${ARIANG_DIR}/*
unzip -d ${ARIANG_DIR}/ AriaNg-${ARIANG_VERSION}.zip

echo "Done! Cleaning up"

cd ${ROOT}
rm -rf ${WORKDIR}

echo "Done! Building click"