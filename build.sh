#!/bin/bash
#sudo cpupower frequency-set -g performance

#SEQ=~/Videos/hamilton.y4m
#SEQ=~/Videos/meerkat.y4m
#SEQ=~/Videos/testsrc-1frame.y4m
#SEQ=~/Videos/meerkat_444.y4m
#SEQ=~/Videos/fast-chromasub-y4m/ducks_take_off_420_720p50.y4m
#SEQ=~/Videos/PerfectMeerkat.y4m
#SEQ=~/Videos/subset1-y4m/205_-_Vallée_de_Colca_-_Panorama_-_Juin_2010_-_5_de_6.y4m
#SEQ="/home/ltrudeau/Videos/subset1-y4m/Catedral_de_Toledo.Altar_Mayor_(huge).y4m"
#SEQ=~/Videos/subset1-y4m/Wasserfassstelle_von_1898_im_Schanerloch.y4m
#SEQ=~/Videos/subset1-y4m/205_-_Vallée_de_Colca_-_Panorama_-_Juin_2010_-_5_de_6.y4m
#SEQ=~/Videos/subset1-y4m/IENA_-_Avenches_-_6.y4m
#SEQ=~/Videos/subset1-y4m/Washington_Monument,_Washington,_D.C._04037u_original.y4m
#SEQ=~/Videos/subset1-y4m/US_Navy_111117-N-UB993-082_A_Sailor_examines_a_patient_during_drill.y4m
#SEQ=~/Videos/akiyo_cif_short.y4m
#SEQ=~/Videos/Netflix_Aerial_4096x2160_60fps_10bit_420-1frame.y4m
#SEQ=~/Videos/football_422_ntsc.y4m
#SEQ=~/Videos/subset1-y4m/Ohashi0806shield.y4m
#SEQ=~/Videos/subset1-y4m/Clovisfest.y4m
#SEQ=~/Videos/subset1-y4m/Seikima-II_20100704_Japan_Expo_32.y4m
#SEQ=~/Videos/objective-1-fast/niklas360p_60f.y4m
#SEQ=~/Videos/objective-1-fast/MINECRAFT_60f_420.y4m
#SEQ=~/Videos/objective-1-fast/shields_640x360_60f.y4m
#SEQ=~/Videos/objective-1-fast/blue_sky_360p_60f.y4m
SEQ=~/Videos/objective-1-fast/red_kayak_360p_60f.y4m

TIGER=0
OWL=0
PONT=0
FRUIT=0
VALGRIND=0
PERF=0
GDB=0
CHROMA422=0
DIFF=0
RR=0
NOT_FATAL=0

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
    "--rr") RR=1 ;;
    "--422") CHROMA422=1 ;;
    "--diff") DIFF=1 ;;
    "--not-fatal") NOT_FATAL=1;;
    *)        set -- "$@" "$arg"
  esac
done

TEST_DEC_CMD=""
if [ $DIFF == 0 ]; then
  set -e
  TEST_DEC_CMD=" --test-decode=fatal"
fi

if [ $NOT_FATAL == 1 ]; then
  TEST_DEC_CMD=""
fi

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
  VALGRIND_CMD="valgrind --vgdb-error=1 --show-leak-kinds=all"  # --track-origins=yes "
fi
PERF_CMD=""
if [ $PERF == 1 ]; then
  PERF_CMD="perf stat -r 5 "
fi
GDB_CMD=""
if [ $GDB == 1 ]; then
  GDB_CMD="gdb --args " #"-ex=r"
fi
RR_CMD=""
if [ $RR == 1 ]; then
  RR_CMD="rr record -n "
fi
if [ $CHROMA422 == 1 ]; then
  SEQ=~/Videos/football_422_ntsc.y4m
fi
#QP=63
QP=55
#QP=43
#QP=32
#QP=20

# taken from https://github.com/tdaede/rd_tool/blob/master/metrics_gather.sh
AWCY_FLAGS="--codec=av1 --frame-parallel=0 --tile-columns=0 --auto-alt-ref=2 --cpu-used=0 --passes=2 --threads=1 --kf-min-dist=1000 --kf-max-dist=1000 --lag-in-frames=25 --end-usage=q --cq-level=$QP --limit=30"

FLAGS="-v "$TEST_DEC_CMD

make -j4

git log --pretty=oneline -n 1
CMD="$GDB_CMD $PERF_CMD $VALGRIND_CMD ./aomenc $AWCY_FLAGS $FLAGS --ivf -o out.ivf $SEQ $DIFF_ENC_CMD"
echo $CMD
#eval "$CMD"
if [ $DIFF == 1 ]; then
  $RR_CMD $GDB_CMD $PERF_CMD $VALGRIND_CMD ./aomenc $AWCY_FLAGS $FLAGS --ivf -o out.ivf $SEQ > enc.cfl
  $GDB_CMD ./aomdec -o out.y4m out.ivf $DIFF_DEC_CMD > dec.cfl
else
  $RR_CMD $GDB_CMD $PERF_CMD $VALGRIND_CMD ./aomenc $AWCY_FLAGS $FLAGS --ivf -o out.ivf $SEQ
  $GDB_CMD ./aomdec -o out.y4m out.ivf $DIFF_DEC_CMD
fi

# compute psnr
../../daala/tools/dump_psnr out.y4m $SEQ

# compute CIEDE2000
#echo CIEDE2000
../../daala/tools/dump_ciede2000.py out.y4m $SEQ

# Create a PNG and View it
../../daala/tools/y4m2png -o out.png out.y4m
eog out.png
#mpv --loop --pause out.y4m
#examples/analyzer out.ivf

#sudo cpupower frequency-set -g powersave

if [ $DIFF == 1 ]; then
  vimdiff enc.cfl dec.cfl
fi
