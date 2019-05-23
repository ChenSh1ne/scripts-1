#!/bin/bash

#PBS -l mem=16gb,nodes=1:ppn=3,walltime=24:00:00
#PBS -e error/${s1}.${s2}.step5.err
#PBS -o output/${s1}.${s2}.step5.out
#PBS -d .

# Must execute step4_chain.sh first, which
# generates the file ${s1}.${s2}.all.chain in MultiSpeciesAlignments/chain/

module load UCSCtools

chainPreNet chain/${s1}.${s2}.all.chain genomes/${s1}_allfiles/${s1}.info genomes/${s2}_allfiles/${s2}.info stdout | \
chainNet stdin -minSpace=1 genomes/${s1}_allfiles/${s1}.info genomes/${s2}_allfiles/${s2}.info stdout /dev/null | \
netSyntenic stdin net/${s1}.${s2}.noClass.net

