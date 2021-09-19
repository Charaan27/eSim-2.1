#!/bin/bash

# This script can be used to cross compile ngspice
#   for windows on a linux machine.
# The result is a zip file,
#   which is intended to be unziped to c:\
#
# You can invoke this script with no argument,
#   whereupon it will compile a 32 bit windows executable
# or with argument "64"
#   to compile a 64 bit windows executable
#
# On debian gnu/linux you will need these packages:
#    mingw-64 make automake libtool bison flex
#
# (compile "time ./cross-compile.sh")
# (compile "time ./cross-compile.sh 64")

set -e

if test "$1" = "64"; then
    release="release-mingw-64"
    dstzip="ngspice-mingw-64.zip"
    host="x86_64-w64-mingw32"
    dst="C:/Spice64"
else
    release="release-mingw-32"
    dstzip="ngspice-mingw-32.zip"
    host="i686-w64-mingw32"
    dst="C:/Spice"
fi

./autogen.sh

rm -rf "./$release"
mkdir -p "./$release"

(
    cd "./$release" && \
        ../configure \
            --build=$(../config.guess) \
            --host="$host" \
            --prefix="$dst" \
            --exec-prefix="$dst" \
            --with-wingui --enable-xspice --enable-cider --disable-debug
)

make -C "./$release" -k -j6
make -C "./$release" -k -j6 DESTDIR="$(pwd)/$release/" install

( cd "./$release/C:/" && zip -r - . ) > "./$release/$dstzip"

echo "unzip this ./$release/$dstzip to the destination directory c:\\"
