#!/bin/bash
set -e

if [ -f ../makefile ]; then
  make distclean
fi

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
AWCY_FLAGS="--enable-av1 --disable-unit-tests --disable-docs"

FLAGS="--enable-experimental --enable-pvq --enable-dct_only --enable-cfl --enable-debug"

../configure $AWCY_FLAGS $FLAGS

