#!/bin/bash

QP=43
SUBSET="subset3"
VIDEO_FOLDER=/home/ltrudeau/Videos/${SUBSET}-y4m

# You better have more than 1 CPU if you are going to run this
NUM_CPU=$(($(nproc)-2))   # Let's not take all the CPUs
SLEEP_TIME=2              # Resource polling interval

# Store actual encoder/decoder output here
OUT_FOLDER=${SUBSET}_out_${QP}    
mkdir $OUT_FOLDER

# Store probability CSV files here
PROB_FOLDER=${SUBSET}_prob_${QP}
mkdir $PROB_FOLDER

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP"

FLAGS="-v --test-decode=fatal"

i=0
echo $VIDEO_FOLDER
for f in ${VIDEO_FOLDER}/*.y4m; do
  filename=$(basename "$f")
  filename="${filename%.*}"
  ./aomenc $AWCY_FLAGS $FLAGS --ivf -o ${OUT_FOLDER}/${filename}.ivf $f & 
  i=$((i+1))
  while [ $i -gt $NUM_CPU ]
  do
    sleep $SLEEP_TIME
    i=`ps --no-headers -o pid --ppid=$$ | wc -w`
    if [[ $i =~ '^[0-9]+$' ]] ; then
      i=$NUM_CPU
    fi
    if [ $i -eq 0 ] ; then
      break
    fi
  done
done

wait

i=0
for f in ${VIDEO_FOLDER}/*.y4m; do
  filename=$(basename "$f")
  filename="${filename%.*}"
  ./aomdec -o "${OUT_FOLDER}/${filename}.y4m" "${OUT_FOLDER}/${filename}.ivf" > ${PROB_FOLDER}/${filename}.csv &
  i=$((i+1))
  while [ $i -gt $NUM_CPU ]
  do
    sleep 1 # This is way too long for the decoder, 
    i=`ps --no-headers -o pid --ppid=$$ | wc -w`
    if [[ $i =~ '^[0-9]+$' ]] ; then
      i=$NUM_CPU
    fi
  done
done

wait
