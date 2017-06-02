#!/bin/bash
set -e

SUBSET1=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--subset1") SUBSET=1 ;;
    *)        set -- "$@" "$arg"
  esac
done

if [ $SUBSET1 == 1 ]; then
  VIDEO_FOLDER=~/Videos/subset1-y4m
fi

if [ -z $VIDEO_FOLDER ]; then
  VIDEO_FOLDER=~/Videos/fast-test-y4m
fi

JOB_NAME=$1
if [ -z $JOB_NAME ]; then
  JOB_NAME="out"
fi

DAALA_ROOT=~/Workspace/daala
TOOLS_ROOT=$DAALA_ROOT
AOM_BUILD_ROOT=~/Workspace/aom-build

AOM_ROOT=$(pwd)

export TOOLS_ROOT
export AOM_ROOT

export EXTRA_OPTS=$EXTRA_OPTS

RANGE="20 32 43 55"
export RANGE

MASTER_TOTAL=$(pwd)/master

make -j5

git log --pretty=oneline -n 1
rm -fr $JOB_NAME
mkdir -p $JOB_NAME
pushd $JOB_NAME
${DAALA_ROOT}/tools/rd_collect.sh av1 ${VIDEO_FOLDER}/*.y4m
${DAALA_ROOT}/tools/rd_average.sh *.out

for f in *.y4m; do
  echo $f
  ${DAALA_ROOT}/tools/y4m2png -o ${f}.png $f > /dev/null 2>&1
done

echo $MASTER_TOTAL
if [ -e $MASTER_TOTAL ]; then
  $AOM_BUILD_ROOT/compare.sh $MASTER_TOTAL .
else
  cat total.out
fi

popd
nomacs $JOB_NAME > /dev/null 2>&1
