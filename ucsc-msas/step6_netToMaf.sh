#!/bin/bash

#PBS -l mem=16gb,nodes=1:ppn=2,walltime=24:00:00
#PBS -d .
#PBS -e error/${s1}.${s2}.step6.err
#PBS -o output/${s1}.${s2}.step6.out

module load UCSCtools

netToAxt -verbose=0 net/${s1}.${s2}.noClass.net chain/${s1}.${s2}.all.chain \
	 genomes/${s1}_allfiles/${s1}.2bit genomes/${s2}_allfiles/${s2}.2bit stdout | \
    axtSort stdin net/${s1}.${s2}.net.axt

axtToMaf -tPrefix=${s1}. -qPrefix=${s2}. ${s1}.${s2}.net.axt genomes/${s1}_allfiles/${s1}.info \
	 genomes/${s2}_allfiles/${s2}.info multiz/${s1}.${s2}.net.maf


