#!/bin/bash
set -e

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
AWCY_FLAGS="--enable-av1 --disable-unit-tests --disable-docs"

FLAGS="--enable-debug --enable-experimental"

CFL=0
PVQ=0
DAALA_DCT=0
LIMIT=0
while getopts ":c --long cfl:p --long pvq:d --long daaladct:l --long limit_4x4:" opt; do
  case $opt in
    c)
      CFL=1
      PVQ=1
      ;;
    p)
      PVQ=1
      ;;
    d)
      DAALA_DCT=1
      ;;
    l)
      LIMIT=1
  esac
done


if [ $CFL == 1 ]; then
  FLAGS=$FLAGS" --enable-cfl"
fi
if [ $PVQ == 1 ]; then
  FLAGS=$FLAGS" --enable-pvq"
fi
if [ $DAALA_DCT == 1 ]; then
  FLAGS=$FLAGS" --enable-daala_dct"
fi
if [ $LIMIT == 1 ]; then
  FLAGS=$FLAGS" --enable-limit_4x4"
fi

if [ -f ./Makefile ]; then
  make clean
  make distclean
  clear
  echo clean + distclean
fi

echo ========================================
echo "AWCY_FLAGS="$AWCY_FLAGS
echo "FLAGS="$FLAGS
echo ========================================

../configure $AWCY_FLAGS $FLAGS

