#!/bin/bash

#PBS -l mem=8gb,nodes=1:ppn=1,walltime=14:00:00:00
#PBS -d .
#PBS -e error/${S}/${S}.${PBS_ARRAYID}.err
#PBS -o output/${S}/${S}.${PBS_ARRAYID}.out

. ~/.bashrc
bash cluster_scripts/${S}/${S}_$(printf "%04d" $PBS_ARRAYID)


