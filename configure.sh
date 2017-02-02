#!/bin/bash
set -e

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
AWCY_FLAGS="--enable-av1 --disable-unit-tests --disable-docs"

FLAGS="--enable-debug --enable-experimental"

CFL=0
PVQ=0
while getopts "::c --long cfl::p --long pvq" opt; do
  case $opt in
    c)
      CFL=1
      PVQ=1
      ;;
    p)
      PVQ=1
      ;;
  esac
done


if [ $CFL == 1 ]; then
  FLAGS=$FLAGS" --enable-cfl"
fi
if [ $PVQ == 1 ]; then
  FLAGS=$FLAGS" --enable-pvq"
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

