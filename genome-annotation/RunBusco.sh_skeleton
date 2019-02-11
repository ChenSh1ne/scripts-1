#!/bin/bash

#PBS -d .
#PBS -e error/${S}_${D}.busco.err
#PBS -o output/${S}_${D}.busco.out
#PBS -l mem=24gb,nodes=1:ppn=16,walltime=96:00:00

. ~/.bashrc

module load busco blast hmmer

python run_BUSCO.py -i ${S}.fa \
       -o ${S}_endo \
       -c 16 \
       -m geno \
       -l $progs/lib/endopterygota_odb9/ \
       -t ${S}_endo_tmp \
       -f \
       -z \
       --long \
       
       
       



       
