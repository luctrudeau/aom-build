#!/bin/bash
set -e

VIDEO_PATH=~/Videos/subset1-y4m/

QP=55

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP"

FLAGS="--test-decode=fatal"

OUT=out
while getopts ":o --long output" opt; do
  case $opt in
    o)
      OUT=$OPTARG
      ;;
  esac
done

OUT_WEBM=$OUT/webm
OUT_Y4M=$OUT/y4m
OUT_PNG=$OUT/png

mkdir -p $OUT
mkdir -p $OUT_WEBM
mkdir -p $OUT_Y4M
mkdir -p $OUT_PNG

for f in ${VIDEO_PATH}*.y4m;
do
  NAME=$(basename -s .y4m $f)
  ./aomenc $AWCY_FLAGS $FLAGS -o $OUT_WEBM/$NAME.webm $f &
done
wait

for f in ${VIDEO_PATH}*.y4m;
do
  NAME=$(basename -s .y4m $f)
  ./aomdec -o $OUT_Y4M/$NAME.y4m $OUT_WEBM/$NAME.webm

  # Create a PNG and View it
  ../../daala/tools/y4m2png -o $OUT_PNG/$NAME.png $OUT_Y4M/$NAME.y4m
done

