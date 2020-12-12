#!/bin/bash

#This script demonstrates the steps to use simpoints with gem5
# Source: Gem5 official Documentation, Stackoverflow and other sources on the internet.
PATH="test_run/Results/Checkpointing"
BENCHMARK="lbm"

# Generating BBV
# build/ARM/gem5.opt -d $PATH/BBV/$BENCHMARK configs/spec2k6/run.py -b $BENCHMARK\
#  --simpoint-profile --simpoint-interval 10000000 --cpu-type=NonCachingSimpleCPU

#Running Simpoint (Already Built)
# For building, see this: http://cluelessram.blogspot.com/2017/10/using-simpoint-in-gem5-to-speed-up_11.html

# gzip -d $PATH/BBV/$BENCHMARK/simpoint.bb.gz

# mkdir $PATH/BBV/$BENCHMARK/SimPoint/
touch $PATH/BBV/$BENCHMARK/SimPoint/simpoints
touch $PATH/BBV/$BENCHMARK/SimPoint/weights

SimPoint/SimPoint.3.2/bin/simpoint -loadFVFile $PATH/BBV/$BENCHMARK/simpoint.bb -maxK 30\
 -saveSimpoints $PATH/BBV/$BENCHMARK/SimPoint/simpoints -saveSimpointWeights\
 $PATH/BBV/$BENCHMARK/SimPoint/weights

# Take Checkpoints in Gem5
build/ARM/gem5.opt -d $PATH/Checkpoint/$BENCHMARK configs/spec2k6/run.py\
 --take-simpoint-checkpoint=$PATH/BBV/$BENCHMARK/SimPoint/simpoints,$PATH/BBV/$BENCHMARK/SimPoint/weights,\
10000000,50000000 -b $BENCHMARK --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4\
 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# Restore Checkpoints in Gem5
# Replace 12 with the number of checkpoints generated for that benchmark
# num_simpoints=$(< "$PATH/BBV/$BENCHMARK/SimPoint/simpoints" wc -l)
# echo num_simpoints
# for ((n=1; n<=12; n++))
# do 
# build/ARM/gem5.opt -d $PATH/RestoreCheckpoint/$BENCHMARK/c$n configs/spec2k6/run.py -b $BENCHMARK\
#  --restore-simpoint-checkpoint -r $n --checkpoint-dir $PATH/Checkpoint/$BENCHMARK --cpu-type=TimingSimpleCPU\
#  --restore-with-cpu=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4\
#  --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher
# done 

#NO PREFETCHING
# ./build/ARM/gem5.opt -d Results/No_Prefetching/bzip2 configs/spec2k6/run.py -b bzip2\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=1000000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB

#WITH PREFETCHING OUICK RUN
# ./build/ARM/gem5.opt -d test_run/Results/StrideP/fdp/d8/evictedBlocks/CachePollution/quick_run/mcf configs/spec2k6/run.py -b mcf\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=10000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# #WITH PREFETCHING
# ./build/ARM/gem5.opt -d test_run/Results/StrideP/fdp/d8/evictedBlocks/CachePollution/bzip2 configs/spec2k6/run.py -b bzip2\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher