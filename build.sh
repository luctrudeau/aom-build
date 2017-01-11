#!/bin/bash
set -e

VIDEO_PATH=~/Videos/subset1-y4m/

SEQ=tiger.y4m
QP=55

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP"

FLAGS="--test-decode=fatal"

make

./aomenc $AWCY_FLAGS $FLAGS -o out.webm $VIDEO_PATH$SEQ
./aomdec -o out.y4m out.webm

# Compute PSNR
../../daala/tools/dump_psnr out.y4m $VIDEO_PATH$SEQ

# Create a PNG and View it
../../daala/tools/y4m2png -o out.png out.y4m
eog out.png
