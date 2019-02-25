#!/bin/bash

#PBS -d .
#PBS -e error/${S}.genemark.err
#PBS -o output/${S}.genemark.out
#PBS -l mem=8gb,nodes=1:ppn=20,walltime=24:00:00

. ~/.bashrc

perl $progs/gm_et_linux_64/gmes_petap/gmes_petap.pl \
     --ES \
     --soft_mask 10 \
     --cores 20 \
     --max_intron 100000 \
     --sequence ${S}.fa
     
     
     
