#!/bin/bash
#This is a file to run a benchmark. Doing it to avoid so many paramenters on shell.
# STRING="Running a benchmark"
# echo $STRING
# Repeat this for other benchmarks as well.

#NO PREFETCHING
./build/ARM/gem5.opt -d Results/No_Prefetching/bzip2 configs/spec2k6/run.py -b bzip2\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=1000000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB

#WITH PREFETCHING
# ./build/ARM/gem5.opt -d test_run/Results/StrideP/fdp/d8/bzip2 configs/spec2k6/run.py -b bzip2\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=50000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher
