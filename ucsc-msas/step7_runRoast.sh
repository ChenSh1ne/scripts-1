#!/bin/bash

#PBS -e error/${T}-centricRoast.step7.err
#PBS -o output/${T}-centricRoast.step7.out
#PBS -d .
#PBS -l mem=8gb,nodes=1:ppn=1,walltime=72:00:00

. ~/.bashrc

module load UCSCtools

mkdir temp

roast + T=temp E=${T} \
      "(dana ((dyak dere) ((dsim dsec) dmel)))" \
      maf/${T}.*.sing.maf multiz/${T}-centricRoast.maf
