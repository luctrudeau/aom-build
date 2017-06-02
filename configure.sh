#!/bin/bash
set -e

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
AWCY_FLAGS=" --enable-av1 --disable-unit-tests --disable-docs --enable-inspection --enable-accounting --enable-analyzer"

# Fail on asserts
FLAGS="--enable-debug --enable-experimental --disable-cdef --enable-aom_highbitdepth"

# Sanitizer Flags
SAN_CFLAGS="-fsanitize=address,undefined -Wformat -Werror=format-security -Werror=array-bounds -g"
SAN_LDFLAGS="-fsanitize=address,undefined"

CFL=0
PVQ_CFL=0
PVQ=0
DAALA_TX=0
LIMIT_TX_4X4=0
LIMIT_TX_8X8=0
HBD=0
USE_C_TX=0
UV_DC_PRED_ONLY=0
SANITIZE=0
ANALYZER=0
EC_ADAPT=0
CHROMA_2X2=0
CHROMA_SUB8X8=0
EC_SMALLMUL=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--pvq_cfl") PVQ_CFL=1 ;;
    "--cfl") CFL=1 ;;
    "--ec_adapt") EC_ADAPT=1 ;;
    "--chroma_2x2") CHROMA_2X2=1 ;;
    "--chroma_sub8x8") CHROMA_SUB8X8=1 ;;
    "--pvq") PVQ=1 ;;
    "--daala_tx") DAALA_TX=1 ;;
    "--limit_tx_4x4") LIMIT_TX_4X4=1 ;;
    "--limit_tx_8x8") LIMIT_TX_8X8=1 ;;
    "--hbd") HBD=1 ;;
    "--use_c_tx") USE_C_TX=1 ;;
    "--uv_dc_pred_only") UV_DC_PRED_ONLY=1 ;;
    "--sanitize") SANITIZE=1 ;;
    "--analyzer") ANALYZER=1 ;;
    "--smallmul") EC_SMALLMUL=1 ;;
    *)        set -- "$@" "$arg"
  esac
done

if [ $CFL == 1 ]; then
  FLAGS=$FLAGS" --enable-cfl"
fi
if [ $PVQ_CFL == 1 ]; then
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
if [ $HBD == 1 ]; then
  FLAGS=$FLAGS" --enable-highbitdepth"
fi
if [ $USE_C_TX == 1 ]; then
  FLAGS=$FLAGS" --enable-use_c_tx"
fi
if [ $UV_DC_PRED_ONLY == 1 ]; then
  FLAGS=$FLAGS" --enable-uv_dc_pred_only"
fi
if [ $ANALYZER == 1 ]; then
  FLAGS=$FLAGS" --enable-analyzer"
fi
if [ $EC_ADAPT == 1 ]; then
  FLAGS=$FLAGS" --enable-ec_adapt"
fi
if [ $CHROMA_2X2 == 1 ]; then
  FLAGS=$FLAGS" --enable-chroma_2x2"
fi
if [ $CHROMA_SUB8X8 == 1 ]; then
  FLAGS=$FLAGS" --enable-chroma_sub8x8"
fi
if [ $EC_SMALLMUL == 1 ]; then
  FLAGS=$FLAGS" --enable-ec_smallmul"
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
