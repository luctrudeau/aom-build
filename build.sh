#!/bin/bash
set -e

SEQ=~/Videos/hamilton.y4m

TIGER=0
OWL=0
VALGRIND=0
PERF=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--tiger") TIGER=1 ;;
    "--owl") OWL=1 ;;
    "--valgrind") VALGRIND=1 ;;
    "--perf") PERF=1 ;;
    *)        set -- "$@" "$arg"
  esac
done


if [ $TIGER == 1 ]; then
  SEQ=~/Videos/subset1-y4m/tiger.y4m
fi
if [ $OWL == 1 ]; then
  SEQ=~/Videos/owl.y4m
fi
VALGRIND_CMD=""
if [ $VALGRIND == 1 ]; then
  VALGRIND_CMD="valgrind " #--leak-check=full --show-leak-kinds=all"
fi
PERF_CMD=""
if [ $PERF == 1 ]; then
  PERF_CMD="perf stat -r 5 "
fi

QP=55

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP"

FLAGS="--test-decode=fatal"

make -j5

git log --pretty=oneline -n 1
CMD="$PERF_CMD $VALGRIND_CMD ./aomenc $AWCY_FLAGS $FLAGS -o out.webm $SEQ"
echo $CMD
`$CMD`
./aomdec -o out.y4m out.webm

# Compute PSNR
../../daala/tools/dump_psnr out.y4m $SEQ

# Create a PNG and View it
../../daala/tools/y4m2png -o out.png out.y4m
eog out.png
