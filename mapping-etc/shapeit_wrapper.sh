#!/bin/bash

#PBS -d .
#PBS -l mem=8gb,nodes=1:ppn=4,walltime=48:00:00
#PBS -e error/shapeit.chunk${N}.${PBS_ARRAYID}.err
#PBS -o output/shapeit.chunk${N}.${PBS_ARRAYID}.out

module load bcftools shapeit/2.12

S=`head -n $PBS_ARRAYID chunk${N} | tail -n 1` bash RunShapeit_forWrap.sh

