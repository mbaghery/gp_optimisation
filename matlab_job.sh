#!/bin/bash
#$ -S /bin/bash
#
# MPI-PKS script for MATLAB job submission with 'qsub'.
# For more information, see
#    http://www.pks.mpg.de/closed/getting_started/MATLAB.html
# (Last change of this file: $Id: d3cfafce1988f506e9a0675f57dd7ed3762979de $)


# Mandatory hardware requirements
# h_rss – Memory limit (resident set size; eg. h_rss=512M);
# h_fsize – File size limit (eg. h_fsize=12G);
# h_cpu – CPU time limit (eg. h_cpu=10:00:00 HH:MM:SS);
# hw I don't know yet
#$ -l h_rss=1000M,h_fsize=1000M,h_cpu=24:00:00,hw=x86_64


# Specify the parallel environment and the necessary number of slots.
#$ -pe smp 13

noFeatures="8"

source="$HOME/Documents/MATLAB/Optimisation/*"
scratch="/scratch/$USER/matlab$noFeatures"
results="/$HOME/tmp/ausb60"

# 1)  Copy files from your own computer to the server
# This scratch is on the server, not my own computer.
mkdir -p $scratch  # -p: Create parent directories if necessary.
cd $scratch
cp -r $source $scratch  # -r: recursively

# 2)  Actual Work
matlab -nodisplay -singleCompThread -r "cd $scratch; noFeatures=$noFeatures, main; quit"

# 3) Copy files back from the scratch disk to your own computer
cd
cp -r $scratch/trainSets/Koudai$noFeatures.mat $results
rm -rf $scratch   # clean up



# This is what the matlab code should look like:
# parpool(noWorkers);
# ...
# delete(gcp('nocreate'));

