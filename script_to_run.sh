#!/bin/bash
#This is a file to run a benchmark. Doing it to avoid so many paramenters on shell.
# STRING="Running a benchmark"
# echo $STRING
# Repeat this for other benchmarks as well.

#NO PREFETCHING
# ./build/ARM/gem5.opt -d Results/No_Prefetching/bzip2 configs/spec2k6/run.py -b bzip2\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=1000000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB

#WITH PREFETCHING
./build/ARM/gem5.opt -d Results/StrideP/d4/bzip2 configs/spec2k6/run.py -b bzip2\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/perlbench configs/spec2k6/run.py -b perlbench\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/gromacs configs/spec2k6/run.py -b gromacs\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/namd configs/spec2k6/run.py -b namd\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

# ./build/ARM/gem5.opt -d Results/StrideP/d4/gobmk configs/spec2k6/run.py -b gobmk\
#  --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
#  --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
#  --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/calculix configs/spec2k6/run.py -b calculix\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/sjeng configs/spec2k6/run.py -b sjeng\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/mcf configs/spec2k6/run.py -b mcf\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/milc configs/spec2k6/run.py -b milc\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/soplex configs/spec2k6/run.py -b soplex\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/libquantum configs/spec2k6/run.py -b libquantum\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/lbm configs/spec2k6/run.py -b lbm\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher

./build/ARM/gem5.opt -d Results/StrideP/d4/omnetpp configs/spec2k6/run.py -b omnetpp\
 --fast-forward=1000000000 --warmup-insts=50000000 --standard-switch=50000000 --maxinsts=250000000\
 --cpu-type=DerivO3CPU --sys-clock=4GHz --caches --l2cache --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --l1d_size=64kB\
 --l1i_size=64kB --l2_size=1MB --l2-hwp-type=StridePrefetcher