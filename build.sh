#!/bin/bash
set -e

#SEQ=~/Videos/hamilton.y4m
SEQ=~/Videos/testsrc-1frame.y4m
#SEQ=~/Videos/meerkat_444.y4m
#SEQ=~/Videos/ducks_take_off_444_720p50_frame1.y4m
#SEQ=~/Videos/PerfectMeerkat.y4m
#SEQ=~/Videos/subset1-y4m/205_-_Vallée_de_Colca_-_Panorama_-_Juin_2010_-_5_de_6.y4m
#SEQ="/home/ltrudeau/Videos/subset1-y4m/Catedral_de_Toledo.Altar_Mayor_(huge).y4m"
#eqz:EQ=~/Videos/subset1-y4m/Wasserfassstelle_von_1898_im_Schanerloch.y4m
#SEQ=~/Videos/subset1-y4m/205_-_Vallée_de_Colca_-_Panorama_-_Juin_2010_-_5_de_6.y4m
#SEQ=~/Videos/subset1-y4m/IENA_-_Avenches_-_6.y4m
#SEQ=~/Videos/subset1-y4m/Washington_Monument,_Washington,_D.C._04037u_original.y4m
#SEQ=~/Videos/subset1-y4m/US_Navy_111117-N-UB993-082_A_Sailor_examines_a_patient_during_drill.y4m
#SEQ=~/Videos/akiyo_cif_short.y4m
#SEQ=~/Videos/Netflix_Aerial_4096x2160_60fps_10bit_420-1frame.y4m
#SEQ=~/Videos/football_422_ntsc.y4m

TIGER=0
OWL=0
PONT=0
FRUIT=0
VALGRIND=0
PERF=0
GDB=0

for arg in "$@"; do
  shift
  case "$arg" in
    "--tiger") TIGER=1 ;;
    "--owl") OWL=1 ;;
    "--pont") PONT=1 ;;
    "--fruit") FRUIT=1 ;;
    "--valgrind") VALGRIND=1 ;;
    "--perf") PERF=1 ;;
    "--gdb") GDB=1 ;;
    *)        set -- "$@" "$arg"
  esac
done


if [ $TIGER == 1 ]; then
  SEQ=~/Videos/subset1-y4m/tiger.y4m
fi
if [ $OWL == 1 ]; then
  SEQ=~/Videos/owl.y4m
fi
if [ $PONT == 1 ]; then
  SEQ=~/Videos/subset1-y4m/125_-_Québec_-_Pont_de_Québec_de_nuit_-_Septembre_2009.y4m
fi
if [ $FRUIT == 1 ]; then
  SEQ=~/Videos/subset1-y4m/Fruits_oranges,_jardin_japonais_2.y4m
fi
VALGRIND_CMD=""
if [ $VALGRIND == 1 ]; then
  VALGRIND_CMD="valgrind --leak-check=full --vgdb-error=1 --show-leak-kinds=all"  # --track-origins=yes "
fi
PERF_CMD=""
if [ $PERF == 1 ]; then
  PERF_CMD="perf stat -r 5 "
fi
GDB_CMD=""
if [ $GDB == 1 ]; then
  GDB_CMD="gdb -ex=r --args "
fi

#QP=63
QP=55
#QP=43
#QP=32
#QP=20

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP --limit=1"

FLAGS="-v --test-decode=fatal"

make -j5

git log --pretty=oneline -n 1
CMD="$GDB_CMD $PERF_CMD $VALGRIND_CMD ./aomenc $AWCY_FLAGS $FLAGS --ivf -o out.ivf $SEQ"
echo $CMD
#eval "$CMD"
$GDB_CMD $PERF_CMD $VALGRIND_CMD ./aomenc $AWCY_FLAGS $FLAGS --ivf -o out.ivf $SEQ
./aomdec -o out.y4m out.ivf

# compute psnr
../../daala/tools/dump_psnr out.y4m $SEQ

# compute CIEDE2000
#echo CIEDE2000
#../../daala/tools/dump_ciede2000.py out.y4m $SEQ


# Create a PNG and View it
../../daala/tools/y4m2png -o out.png out.y4m
eog out.png
#mpv --loop --pause out.y4m
#examples/analyzer out.ivf
