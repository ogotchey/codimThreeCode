#!/bin/bash
#SBATCH --job-name=Macaulay2_Experiments_degSeq_1
#SBATCH --output=%x.o%j
#SBATCH --error=%x.e%j
#SBATCH --partition nocona
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=3994MB 
#SBATCH --mail-user=<orin.gotchey@ttu.edu>
#SBATCH --mail-type=ALL

export GC_LOG_FILE="./gc.log"
export GC_PRINT_STATS="TRUE"
export GC_NPROCS=4
M2 ./supervisor.m2
