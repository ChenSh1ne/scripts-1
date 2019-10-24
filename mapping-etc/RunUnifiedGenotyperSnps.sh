#!/bin/bash

D=`date +%Y%m%d`

#PBS -d .
#PBS -e error/${O}.uger.${D}.err
#PBS -o output/${O}.uger.${D}.out
#PBS -l mem=24gb,nodes=1:ppn=12,walltime=1:00:00:00

################################################################################
#                                                                              #
# Run UnifiedGenotyper with sensible butterfly defaults.                       #
#                                                                              #
# -- Must supply: O = output basename                                          #
#                 R = reference basename                                       #
#                 S = list of bam files                                        #
#                                                                              #
# Assumes your reference is in ./reference/${R}.fa                             #
#                                                                              #
# Ex.                                                                          #
# qsub -v O=mel,R=hmel,S=bams.list -N mel.uger RunUnifiedGenotyperSnps.sh      #
#                                                                              #
################################################################################

module load java-jdk/1.8.0_92 htslib vcftools

mkdir -p genotypes

# Make sure sequence dictionary exists
if [ ! -f reference/${R}.dict ]; then
    java -jar /apps/software/java-jdk-1.8.0_92/picard/2.8.1/picard.jar CreateSequenceDictionary R=reference/${R}.fa
fi

# Run GATK
G=/apps/software/java-jdk-1.8.0_92/gatk/3.8/GenomeAnalysisTK.jar
V=genotypes/${O}.${D}.vcf.gz

java -Xmx24g -jar $G -T UnifiedGenotyper \
   --out $V \
   -R reference/hmel.fa \
   --heterozygosity 0.02 \
   --min_base_quality_score 30 \
   -I bams.list \
   -nt 12 \
   -rf MappingQuality -mmq 30 \
   -drf BadMate

