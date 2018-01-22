#!/bin/bash
set -e

if [ -f ./Makefile ]; then
  git clean -i .
fi

ASAN=0
TSAN=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--asan") ASAN=1 ;;
    "--tsan") TSAN=1 ;;
    *)        set -- "$@" "$arg"
  esac
done

SANITIZER=""
if [ $TSAN == 1 ]; then
  SANITIZER="-DSANITIZE=thread"
fi
if [ $ASAN == 1 ]; then
  SANITIZER="-DSANITIZE=address"
fi

COMPILER="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
CCACHE="-DENABLE_CCACHE=1"

# AWCY Configure flags taken from
# https://github.com/tdaede/awcy/blob/5e8e5324e4835445f1a42c2bfc39e1cb36cecb11/build_codec.sh#L50
AWCY_FLAGS="-DCONFIG_UNIT_TESTS=0 -DENABLE_DOCS=0 -DCMAKE_BUILD_TYPE=Debug"

PARAMS="$COMPILER $AWCY_FLAGS $CCACHE $SANITIZER"

git log --pretty=oneline -n 1
set -x
cmake .. $PARAMS
set +x

