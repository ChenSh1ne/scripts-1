#!/bin/bash

#PBS -d .
#PBS -l mem=8gb,nodes=1:ppn=4,walltime=24:00:00
#PBS -e error/shapeit2.${S}.err
#PBS -o output/shapeit2.${S}.out

module load bcftools shapeit/2.12

I=unphased.snps_indels.named.20190619.bcf

# Get biallelic sites on scaffold of interest
bcftools view -m 2 -M 2 -r $S \
	 --output-type z \
	 --output-file shapeit_vcfs/${S}.vcf.gz \
	 $I

tabix shapeit_vcfs/${S}.vcf.gz

# Gather reads for read-backed phasing
sed "s/REPLACE/$S/g" alithea.pirs > alithea.${S}.bams

extractPIRs --bam alithea.${S}.bams \
	    --vcf shapeit_vcfs/${S}.vcf.gz \
	    --out pirs/${S}.pirs

rm alithea.${S}.bams

# Run phasing on focal group genotypes
O=shapeit_results/${S}.phased

BURNIN=10
PRUNE=10
ITERATIONS=40
PRUNE_STAGES=2
STATES=400
WINDOW=2.0
NE=1000000
RHO=0.004

shapeit -assemble \
	--thread 4 \
	--output-log ${O}.log \
	--input-vcf shapeit_vcfs/${S}.vcf.gz \
	--burn ${BURNIN} \
	--prune ${PRUNE} \
	--main ${ITERATIONS} \
	--run ${PRUNE_STAGES} \
	--states $STATES \
	--window $WINDOW \
	--effective-size $NE \
	--rho $RHO \
	--output-max $O \
	--input-pir pirs/${S}.pirs
	
# Convert phasing files back to vcf
shapeit -convert --thread 4 \
	--output-log ${O}.convert.log \
	--input-haps $O \
	--output-vcf ${O}.vcf

bgzip ${O}.vcf
tabix ${O}.vcf.gz

