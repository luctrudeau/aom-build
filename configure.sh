#!/bin/bash
set -e

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
AWCY_FLAGS=" --disable-unit-tests --disable-docs --enable-av1 --enable-lowbitdepth --disable-highbitdepth --enable-inspection --enable-accounting --enable-analyzer"

# Fail on asserts
FLAGS="--enable-debug --enable-experimental"

# Sanitizer Flags
SAN_CFLAGS="-fsanitize=address,undefined -Wformat -Werror=format-security -Werror=array-bounds -g"
SAN_LDFLAGS="-fsanitize=address,undefined"

CFL=0
PVQ=0
HBD=0
SANITIZE=0
ANALYZER=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--cfl") CFL=1 ;;
    "--chroma_sub8x8") CHROMA_SUB8X8=1 ;;
    "--pvq") PVQ=1 ;;
    "--hbd") HBD=1 ;;
    "--sanitize") SANITIZE=1 ;;
    "--analyzer") ANALYZER=1 ;;
    *)        set -- "$@" "$arg"
  esac
done

if [ $CFL == 1 ]; then
  FLAGS=$FLAGS" --enable-cfl"
fi
if [ $PVQ == 1 ]; then
  FLAGS=$FLAGS" --enable-pvq"
fi
if [ $HBD == 1 ]; then
  FLAGS=$FLAGS" --enable-highbitdepth"
fi
if [ $ANALYZER == 1 ]; then
  FLAGS=$FLAGS" --enable-analyzer"
fi

if [ -f ./Makefile ]; then
  make clean
  make distclean
  clear
  echo clean + distclean
fi

CMD=''
if [ $SANITIZE == 1 ]; then
  echo ======================================== 
  echo               SANITIZER BUILD
  echo CFLAGS="$SAN_CFLAGS"
  echo LDFLAGS="$SAN_LDFLAGS"
  echo ======================================== 
  CMD=$CMD'CFLAGS="$SAN_CFLAGS" LDFLAGS="$SAN_LDFLAGS"'
fi

CMD=$CMD" CFLAGS='-Wall -Wextra -Werror ' ../configure $AWCY_FLAGS $FLAGS"

git log --pretty=oneline -n 1
echo $CMD
eval $CMD
