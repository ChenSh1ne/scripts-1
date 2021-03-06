#!/bin/bash

#PBS -l mem=50gb,nodes=1:ppn=1,walltime=48:00:00
#PBS -d .
#PBS -e error/${s1}.${s2}.rbest.err
#PBS -o output/${s1}.${s2}.rbest.out

# This script was automatically generated by /cluster/bin/scripts/doRecipBest.pl
# It is to be executed on ku in /hive/data/genomes/hg38/bed/lastzOviAri3.2015-01-21/axtChain .
# It nets in both directions to get reciprocal best chains and nets.
# This script will fail if any of its commands fail.

. ~/.bashrc
module load UCSCtools

# Swap s1-best chains to be s2-referenced:
chainStitchId chain/${s1}.${s2}.all.chain stdout | \
    chainSwap stdin stdout | \
    chainSort stdin chain/${s2}.${s1}.tBest.chain

echo "Finished swapping ${s1} and ${s2} chains"

# Net those on sp2 to get sp2-ref'd reciprocal best net:
chainPreNet chain/${s2}.${s1}.tBest.chain genomes/${s2}_allfiles/${s2}.info \
	    genomes/${s1}_allfiles/${s1}.info stdout | \
    chainNet -minSpace=1 -minScore=0 stdin genomes/${s2}_allfiles/${s2}.info \
	     ../genomes/${s1}_allfiles/${s1}.info stdout /dev/null | \
    netSyntenic stdin stdout | \
    gzip -c > net/${s2}.${s1}.rbest.net.gz

echo "Finished netting ${s2}"

# Extract sp2-ref'd reciprocal best chain:
netChainSubset net/${s2}.${s1}.rbest.net.gz chain/${s2}.${s1}.tBest.chain stdout | \
    chainStitchId stdin stdout | \
    gzip -c > chain/${s2}.${s1}.rbest.chain.gz

echo "Finished extracting ${s2}-referenced RB chain"

# Swap to get sp1-ref'd reciprocal best chain:
chainSwap chain/${s2}.${s1}.rbest.chain.gz stdout | \
    chainSort stdin stdout | \
    gzip -c > chain/${s1}.${s2}.rbest.chain.gz

echo "Finished extracting ${s1}-referenced RB chain"

# Net those on sp1 to get sp1-ref'd reciprocal best net:
chainPreNet chain/${s1}.${s2}.rbest.chain.gz genomes/${s1}_allfiles/${s1}.info \
	    genomes/${s2}_allfiles/${s2}.info stdout | \
    chainNet -minSpace=1 -minScore=0 stdin genomes/${s1}_allfiles/${s1}.info \
	     genomes/${s2}_allfiles/${s2}.info stdout /dev/null | \
    netSyntenic stdin stdout | \
    gzip -c > net/${s1}.${s2}.rbest.net.gz

echo "Finished netting on ${s1}-referenced RB chain"

# Create files for testing coverage of *.rbest.*.
netToBed -maxGap=1 ${s2}.${s1}.rbest.net.gz ${s2}.${s1}.rbest.net.bed
netToBed -maxGap=1 ${s1}.${s2}.rbest.net.gz ${s1}.${s2}.rbest.net.bed

chainToPsl chain/${s2}.${s1}.rbest.chain.gz genomes/${s2}_allfiles/${s2}.info \
	   genomes/${s1}_allfiles/${s1}.info genomes/${s2}_allfiles/${s2}.2bit \
	   genomes/${s1}.2bit chain/${s2}.${s1}.rbest.chain.psl

chainToPsl chain/${s1}.${s2}.rbest.chain.gz genomes/${s1}_allfiles/${s1}.info \
	   genomes/${s2}_allfiles/${s2}.info genomes/${s1}_allfiles/${s1}.2bit \
	   genomes/${s2}_allfiles/${s2}.2bit chain/${s1}.${s2}.rbest.chain.psl

echo "Finished creating files for testing single coverage of RB files"
  
# Verify that all coverage figures are equal:
tChCov=`awk '{print $19;}' chain/${s1}.${s2}.rbest.chain.psl | sed -e 's/,/\n/g' | awk 'BEGIN {N = 0;} {N += $1;} END {printf "%d\n", N;}'`
qChCov=`awk '{print $19;}' chain/${s2}.${s1}.rbest.chain.psl | sed -e 's/,/\n/g' | awk 'BEGIN {N = 0;} {N += $1;} END {printf "%d\n", N;}'`
tNetCov=`awk 'BEGIN {N = 0;} {N += ($3 - $2);} END {printf "%d\n", N;}' net/${s1}.${s2}.rbest.net.bed`
qNetCov=`awk 'BEGIN {N = 0;} {N += ($3 - $2);} END {printf "%d\n", N;}' net/${s2}.${s1}.rbest.net.bed`

if [ "$tChCov" != "$qChCov" ]; then
  echo "Warning: ${s1} rbest chain coverage $tChCov != ${s2} $qChCov"
fi

if [ "$tNetCov" != "$qNetCov" ]; then
  echo "Warning: ${s1} rbest net coverage $tNetCov != ${s2} $qNetCov"
fi

if [ "$tChCov" != "$tNetCov" ]; then
  echo "Warning: ${s1} rbest chain coverage $tChCov != net cov $tNetCov"
fi


mkdir -p experiments

mv *.bed *.psl experiments

# Make rbest net axt's download
mkdir -p ../axtRBestNet

netToAxt ${sp1}.${sp2}.rbest.net.gz ${sp1}.${sp2}.rbest.chain.gz \
	 ../genomes/${sp1}.2bit ../genomes/${sp2}.2bit stdout | \
    axtSort stdin stdout | \
    gzip -c > ../axtRBestNet/${sp1}.${sp2}.rbest.axt.gz
    
# Make rbest mafNet for multiz

mkdir -p ../mafRBestNet

axtToMaf -tPrefix=${sp1}. -qPrefix=${sp2}. ../axtRBestNet/${sp1}.${sp2}.rbest.axt.gz \
	 ../genomes/${sp1}.info ../genomes/${sp2}.info stdout | \
    gzip -c > ../mafRBestNet/${sp1}.${sp2}.rbest.maf.gz

