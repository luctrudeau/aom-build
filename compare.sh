#!/bin/bash
set -e

DAALA_ROOT=~/Workspace/daala
BUILD_ROOT=$DAALA_ROOT
JOB_1=$1
JOB_2=$2

if [ -z $JOB_1 ]; then
  JOB_1="master"
fi

if [ -z $JOB_2 ]; then
  JOB_2="out"
fi

REPORT="awcy"

export REPORT
export BUILD_ROOT

${DAALA_ROOT}/tools/matlab/bd_rate.m ${JOB_1}/total.out ${JOB_2}/total.out
#${DAALA_ROOT}/tools/bd_rate.sh ${JOB_1}/total.out ${JOB_2}/total.out
