#!/bin/bash
#This is a file to run a benchmark. Doing it to avoid so many paramenters on shell.
# STRING="Running a benchmark"
# echo $STRING
# Repeat this for other benchmarks as well.
PATH="Results/fdp_w_Pollution/Pth_high/d16/"

#NO PREFETCHING
# ./build/ARM/gem5.opt -d Results/No_Prefetching/bzip2 configs/spec2k6/run.py -b bzip2\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=1000000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB

#WITH PREFETCHING OUICK RUN
./build/ARM/gem5.opt -d $PATH/quick_run/mcf configs/spec2k6/run.py -b mcf\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=10000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# #WITH PREFETCHING
# ./build/ARM/gem5.opt -d $PATH/bzip2 configs/spec2k6/run.py -b bzip2\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# ./build/ARM/gem5.opt -d $PATH/namd configs/spec2k6/run.py -b namd\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# ./build/ARM/gem5.opt -d $PATH/sjeng configs/spec2k6/run.py -b sjeng\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# ./build/ARM/gem5.opt -d $PATH/mcf configs/spec2k6/run.py -b mcf\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# ./build/ARM/gem5.opt -d $PATH/milc configs/spec2k6/run.py -b milc\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# ./build/ARM/gem5.opt -d $PATH/lbm configs/spec2k6/run.py -b lbm\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

#  ./build/ARM/gem5.opt -d $PATH/leslie3d configs/spec2k6/run.py -b leslie3d\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

#  ./build/ARM/gem5.opt -d $PATH/hmmer configs/spec2k6/run.py -b hmmer\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher