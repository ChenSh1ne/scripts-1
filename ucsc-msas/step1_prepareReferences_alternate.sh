#!/bin/bash

#PBS -d .
#PBS -l mem=8gb,nodes=1:ppn=16,walltime=96:00:00
#PBS -e error/${S}.step1.err
#PBS -o output/${S}.step1.out

. ~/.bashrc
module load UCSCtools

##execute from project directory

R="genomes/${S}/${S}"

##format sequences
mkdir -p ${R}	
cp genomes/masking/${S}/masked_fasta/${S}.fa ${R}.fa
faSplit byName ${R}.fa $R/

##prepare necessary files for lastz, conversion of lav to psl

cat ${R}/*.fa > ${R}.rm.fa
faToTwoBit ${R}.rm.fa ${R}.2bit
twoBitInfo ${R}.2bit stdout | sort -k2nr > ${R}.info

##Create a lift file
perl scripts/step1c_partitionSequence.pl 50000000 0 ${R}.2bit ${R}.info 1 -lstDir ${R}_lst > /dev/null
cat ${R}_lst/* > ${R}.parts.list
perl scripts/step1d_constructLiftFile.pl ${R}.info ${R}.parts.list > ${R}.lift

mkdir ${R}_2bit
	
for j in `ls ${R}/ | grep ".fa$"`
    do
        faToTwoBit ${R}/${j} ${R}_2bit/`echo $j | sed 's/\.fa//'`.2bit
done




