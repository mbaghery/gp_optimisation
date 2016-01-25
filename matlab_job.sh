#!/bin/bash
#$ -S /bin/bash


# Mandatory hardware requirements
# h_rss – Memory limit (resident set size; eg. h_rss=512M);
# h_fsize – File size limit (eg. h_fsize=12G);
# h_cpu – CPU time limit (eg. h_cpu=10:00:00 HH:MM:SS);
# hw I don't know yet
#$ -l h_rss=1000M,h_fsize=1000M,h_cpu=24:00:00,hw=x86_64


# Specify the parallel environment and the necessary number of slots (cpus)
#$ -pe smp 16

# no space is acceptable before or after '=' below
noFeatures="6"

source="$HOME/Documents/MATLAB/Optimisation/*"
scratch="/scratch/$USER/matlab$noFeatures"
results="/$HOME/tmp/matlab$noFeatures"

# 1)  Copy files from your own computer to the server
# This scratch is on the server, not my own computer.
mkdir -p $scratch  # -p: Create parent directories if necessary.
mkdir -p $results
cd $scratch
cp -r $source $scratch  # -r: recursively

# 2)  Actual Work
matlab -nodisplay -singleCompThread -r "cd $scratch; noFeatures=$noFeatures, mainParallel; quit"

# 3) Copy files back from the scratch disk to your own computer
cd
cp -r $scratch/qporp_1_1.mat $results
cp -r $scratch/+mex/res/* $results
rm -rf $scratch   # clean up



# This is what the matlab code should look like:
# parpool(noWorkers);
# ...
# delete(gcp('nocreate'));

# command to submit the job file:
# qsub matlab_job.sh

# command to see what the jobs are up to:
# qstat

# command to delete a job
# qdel job_number
