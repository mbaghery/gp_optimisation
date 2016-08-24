#!/bin/bash -i 
#$ -S /bin/bash 


# Mandatory hardware requirements
# h_rss : Memory limit per node (resident set size; eg. h_rss=512M);
# h_fsize : File size limit (eg. h_fsize=12G);
# h_cpu : CPU time limit (eg. h_cpu=10:00:00 HH:MM:SS);
# hw : I don't know
#$ -l h_rss=4G,h_fsize=5G,h_cpu=150:00:00,hw=x86_64,ps=haswell
#$ -M mbaghery@pks.mpg.de

# Specify the parallel environment and the necessary number of slots (cpus)
#$ -pe smp 4

# no space is acceptable before or after '=' below
noFeatures="2"

A0_2=0.375
omega2=0.45
FWHM2=80

source="$HOME/Documents/MATLAB/Optimisation"
scratch="/scratch/$USER/matlab-"$noFeatures"D_"$A0_2"_"$omega2"_"$FWHM2
results="/data2/finite/mbaghery/asym-"$noFeatures"D_"$A0_2"_"$omega2"_"$FWHM2
###cache="/data2/finite/mbaghery/SCID_5000_0.4"

hostname


# 1)  Copy files from my computer to the server
# This scratch is on the server, not my own computer.
mkdir -p $scratch  # -p: Create parent directories if necessary.
mkdir -p $results
cp -r $source/* $scratch
###cp $cache/cache/* $scratch/cache


# 2)  Actual Work
matlab -nodisplay -singleCompThread -r "cd $scratch; noFeatures=$noFeatures, mainParallelAsym; quit"


# 3) Copy files back from the scratch disk to /data2
mv $scratch/wfn $results
mv $scratch/iofiles $results
mv $scratch/SCID.mat $results
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
