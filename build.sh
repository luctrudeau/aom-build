#!/bin/bash
set -e

VIDEO_PATH=~/Videos/subset1-y4m
#VIDEO_PATH=~/Videos/


SEQ=tiger.y4m
#SEQ=eye-bw.y4m
#SEQ=owl.y4m
#SEQ=hamilton.y4m
#SEQ=Eaglefairy_hst_big.y4m
#SEQ=Lufthansa_Aviation_Center_after_sunset_-_Frankfurt_-_Germany_-_near_Airport_Frankfurt_-_Fraport_-_03.y4m
QP=55
#QP=32

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP"

FLAGS="--test-decode=fatal"

make -j5

VALGRIND="" #"valgrind " #--leak-check=full --show-leak-kinds=all"
PERF="" #"perf stat -r 5 "

#valgrind --leak-check=full --show-leak-kinds=all ./aomenc $AWCY_FLAGS $FLAGS -o out.webm $VIDEO_PATH$SEQ
#gdb -ex run --args ./aomenc $AWCY_FLAGS $FLAGS -o out.webm $VIDEO_PATH$SEQ
git log --pretty=oneline -n 1
CMD="$PERF $VALGRIND ./aomenc $AWCY_FLAGS $FLAGS -o out.webm $VIDEO_PATH/$SEQ"
echo $CMD 
`$CMD`
#./aomdec -o out.y4m out.webm

# Compute PSNR
../../daala/tools/dump_psnr out.y4m $VIDEO_PATH$SEQ

# Create a PNG and View it
../../daala/tools/y4m2png -o out.png out.y4m
eog out.png
