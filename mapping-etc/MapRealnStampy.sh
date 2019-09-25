#!/bin/bash

#PBS -d .
#PBS -e error/${S}.${R}.map.err
#PBS -o output/${S}.${R}.map.out
#PBS -l mem=8gb,nodes=1:ppn=16,walltime=96:00:00

module load bowtie2/2.3.0
module load python/2.7.13
module load java-jdk/1.8.0_92

python /apps/software/gcc-6.2.0/stampy/1.0.31/stampy.py \
       -g reference/${R}/${R} \
       -h reference/${R}/${R} \
       --readgroup=ID:${S},LB:${S},PL:illumina,SM:${S} \
       -t 16 \
       --substitutionrate=0.0001 \
       -M trimmed_fastqs/${S}.r1.fq.gz trimmed_fastqs/${S}.r2.fq.gz | \
    samtools view -bS - > stampy_bams/${R}/${S}.raw.bam

samtools sort --threads 16 -m 450M -o stampy_bams/${R}/${S}.sort.bam stampy_bams/${R}/${S}.raw.bam
samtools index stampy_bams/${R}/${S}.sort.bam

# Mark duplicates

java -Xmx8g -jar /apps/software/java-jdk-1.8.0_92/picard/2.8.1/picard.jar MarkDuplicates \
     I=stampy_bams/${R}/${S}.sort.bam \
     O=stampy_bams/${R}/${S}.md.bam \
     M=output/${S}.metrics \
     CREATE_INDEX=true

# Indel Realignment

G=/apps/software/java-jdk-1.8.0_92/gatk/3.8/GenomeAnalysisTK.jar

samtools index stampy_bams/${R}/${S}.md.bam

java -Xmx8g -jar $G -T RealignerTargetCreator \
     -nt 16 \
     -R reference/${R}/${R}.fa \
     -I stampy_bams/${R}/${S}.md.bam \
     -o stampy_bams/${R}/${S}.intervals

java -Xmx8g -jar $G -T IndelRealigner \
     -R reference/${R}/${R}.fa \
     -I stampy_bams/${R}/${S}.md.bam \
     --targetIntervals stampy_bams/${R}/${S}.intervals \
     --out stampy_bams/${R}/${S}.realigned.bam 



