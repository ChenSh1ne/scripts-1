#!/bin/bash
#PBS -l mem=4gb,walltime=6:00:00,nodes=1:ppn=1
#PBS -d .
#PBS -e error/rep${R}.err
#PBS -o cluster_output/rep${R}.out

# Be sure your fam, bed, and bim filenames all have the same root!

# For storing p values
if [ ! -d minvals/ ]; then mkdir minvals; fi

module load gcc/6.2.0 gemma/0.94 plink

# This will get each pair of columns
c1=$($R*2-1)
c2=$($R*2)

# You will need to change the bfile root here from "ForPermutations" to whatever your filename is. Same with the relatedness matrix filename.
gemma -bfile ForPermutations -k ForPermutations.RelatednessMatrix.cXX.txt -hwe 0.001 -miss 0.20 -o rep${R} -lmm 4 -n $c1 $c2 

cut -f 12 output/rep${R}.assoc.txt | grep -v p_wald | sort -k1,1g | head -n1 > minvals/imp_perm_${R}.minval

rm output/rep${R}.assoc.txt output/rep${R}.log.txt




