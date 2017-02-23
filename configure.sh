#!/bin/bash
set -e

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
AWCY_FLAGS="--enable-av1 --disable-unit-tests --disable-docs"

# Fail on asserts
FLAGS="--enable-debug --enable-experimental"

# Sanitizer Flags
SAN_CFLAGS="-fsanitize=address,undefined -Wformat -Werror=format-security -Werror=array-bounds -g"
SAN_LDFLAGS="-fsanitize=address,undefined"

CFL=0
PVQ=0
DAALA_TX=0
LIMIT_TX_4X4=0
LIMIT_TX_8X8=0
DCT_ONLY=0
USE_C_TX=0
UV_DC_PRED_ONLY=0
SANITIZE=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--cfl") CFL=1 ;;
    "--pvq") PVQ=1 ;;
    "--daala_tx") DAALA_TX=1 ;;
    "--limit_tx_4x4") LIMIT_TX_4X4=1 ;;
    "--limit_tx_8x8") LIMIT_TX_8X8=1 ;;
    "--dct_only") DCT_ONLY=1 ;;
    "--use_c_tx") USE_C_TX=1 ;;
    "--uv_dc_pred_only") UV_DC_PRED_ONLY=1 ;;
    "--sanitize") SANITIZE=1 ;;
    *)        set -- "$@" "$arg"
  esac
done

if [ $CFL == 1 ]; then
  FLAGS=$FLAGS" --enable-pvq_cfl"
fi
if [ $PVQ == 1 ]; then
  FLAGS=$FLAGS" --enable-pvq"
fi
if [ $DAALA_TX == 1 ]; then
  FLAGS=$FLAGS" --enable-daala_tx"
fi
if [ $LIMIT_TX_4X4 == 1 ]; then
  FLAGS=$FLAGS" --enable-limit_4x4"
fi
if [ $LIMIT_TX_8X8 == 1 ]; then
  FLAGS=$FLAGS" --enable-limit_8x8"
fi
if [ $DCT_ONLY == 1 ]; then
  FLAGS=$FLAGS" --enable-dct_only"
fi
if [ $USE_C_TX == 1 ]; then
  FLAGS=$FLAGS" --enable-use_c_tx"
fi
if [ $UV_DC_PRED_ONLY == 1 ]; then
  FLAGS=$FLAGS" --enable-uv_dc_pred_only"
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

CMD=$CMD" ../configure $AWCY_FLAGS $FLAGS"

git log --pretty=oneline -n 1
echo $CMD
eval $CMD
