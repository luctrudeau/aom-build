#!/bin/bash
set -e

if [ -f ./Makefile ]; then
  git clean -i .
fi

ASAN=0
TSAN=0
UBSAN=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--asan") ASAN=1 ;;
    "--tsan") TSAN=1 ;;
    "--ubsan") UBSAN=1 ;;
    *)        set -- "$@" "$arg"
  esac
done

#COMPILER="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
CCACHE="-DENABLE_CCACHE=1"

# AWCY Configure flags taken from
# https://github.com/tdaede/awcy/blob/5e8e5324e4835445f1a42c2bfc39e1cb36cecb11/build_codec.sh#L50
AWCY_FLAGS="-DCONFIG_UNIT_TESTS=0 -DENABLE_DOCS=0 -DCMAKE_BUILD_TYPE=Debug"

PARAMS="$AWCY_FLAGS $CCACHE"

git log --pretty=oneline -n 1
set -x
cmake .. $PARAMS
set +x

# taken from https://github.com/tdaede/awcy/blob/master/build_codec.sh
#--enable-lowbitdepth --disable-highbitdepth --disable-unit-tests --enable-analyzer
#AWCY_FLAGS="--disable-unit-tests --disable-docs --enable-av1 --enable-inspection --enable-accounting"

# Fail on asserts
#FLAGS="--enable-debug --enable-experimental"

# Sanitizer Flags
#SAN_CFLAGS="-fsanitize=address,undefined -Wformat -Werror=format-security -Werror=array-bounds -g"
#SAN_LDFLAGS="-fsanitize=address,undefined"
#SAN_CFLAGS="-fsanitize=thread -g"
#SAN_LDFLAGS="-fsanitize=thread"
#SAN_CFLAGS="-fsanitize=memory"
#SAN_LDFLAGS=""

#CFL=0
#INTRABC=0
#TX64X64=0
#RECT_TX_EXT=0
#HBD=0
#SANITIZE=0
#ANALYZER=0
#BIG=0
#DAALATX=0
#TXK_SEL=0
#
#for arg in "$@"; do
#  shift
#  case "$arg" in
#    "--cfl") CFL=1 ;;
#    "--intrabc") INTRABC=1 ;;
#    "--chroma_sub8x8") CHROMA_SUB8X8=1 ;;
#    "--tx64x64") TX64X64=1 ;;
#    "--rect_tx_ext") RECT_TX_EXT=1 ;;
#    "--hbd") HBD=1 ;;
#    "--big") BIG=1 ;;
#    "--sanitize") SANITIZE=1 ;;
#    "--analyzer") ANALYZER=1 ;;
#    "--daalatx") DAALATX=1 ;;
#    "--txk_sel") TXK_SEL=1 ;;
#    *)        set -- "$@" "$arg"
#  esac
#done
#
#if [ $CFL == 1 ]; then
#  FLAGS=$FLAGS" --disable-cfl"
#fi
#if [ $BIG == 1 ]; then
#  FLAGS=$FLAGS" --enable-big_chroma_tx"
#fi
#if [ $INTRABC == 1 ]; then
#  FLAGS=$FLAGS" --enable-intrabc"
#fi
#if [ $TX64X64 == 1 ]; then
#  FLAGS=$FLAGS" --enable-tx64x64"
#fi
#if [ $RECT_TX_EXT == 1 ]; then
#  FLAGS=$FLAGS" --enable-rect_tx_ext"
#fi
#if [ $HBD == 1 ]; then
#  FLAGS=$FLAGS" --enable-highbitdepth"
#fi
#if [ $ANALYZER == 1 ]; then
#  FLAGS=$FLAGS" --enable-analyzer"
#fi
#if [ $DAALATX == 1 ]; then
#  FLAGS=$FLAGS" --enable-daala_tx"
#fi
#if [ $TXK_SEL == 1 ]; then
#  FLAGS=$FLAGS" --enable-txk_sel"
#fi
#
#if [ -f ./Makefile ]; then
#  make clean
#  make distclean
#  clear
#  echo clean + distclean
#fi
#
#CMD=''
#if [ $SANITIZE == 1 ]; then
#  echo ======================================== 
#  echo               SANITIZER BUILD
#  echo CFLAGS="$SAN_CFLAGS"
#  echo LDFLAGS="$SAN_LDFLAGS"
#  echo ======================================== 
#  CMD=$CMD'CFLAGS="$SAN_CFLAGS" LDFLAGS="$SAN_LDFLAGS"'
#fi
#
#WARNINGS="-Wall -Wextra -Werror"
##WARNINGS="-Weverything"
#
#
#CMD=$CMD" CFLAGS='$WARNINGS' ../configure $AWCY_FLAGS $FLAGS"
#
#git log --pretty=oneline -n 1
#echo $CMD
#eval $CMD
