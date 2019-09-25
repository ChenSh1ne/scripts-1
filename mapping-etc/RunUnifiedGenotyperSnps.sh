#!/bin/bash

#PBS -d .
#PBS -e error/uger.snps.20190617.err
#PBS -o output/uger.snps.20190617.out
#PBS -l mem=24gb,nodes=1:ppn=16,walltime=2:00:00:00

module load java-jdk/1.8.0_92 htslib vcftools

G=/apps/software/java-jdk-1.8.0_92/gatk/3.8/GenomeAnalysisTK.jar
O=genotypes/raw.uger.snps.20190617.vcf.gz

java -Xmx24g -jar $G -T UnifiedGenotyper \
   --out $O \
   -R reference/hcyg.fa \
   --heterozygosity 0.02 \
   --min_base_quality_score 30 \
   -stand_call_conf 1000.0 \
   -I bams.list \
   -nt 16 \
   -drf BadMate \
   -rf MappingQuality -mmq 30 

# Preliminary stats
gunzip -c $O | \
    vcftools --vcf - --missing-indv --out `basename $O .vcf.gz` &

gunzip -c $O | \
    vcftools --vcf - --missing-site --out `basename $O .vcf.gz` &

# Stats
gunzip -c $O | vcftools --vcf - --minDP 3 --recode -c | \
    vcftools --vcf - --missing-indv --out `basename $O .vcf.gz`.dp3

gunzip -c $O | vcftools --vcf - --minDP 3 --recode -c | \
    vcftools --vcf - --missing-site --out `basename $O .vcf.gz`.dp3







