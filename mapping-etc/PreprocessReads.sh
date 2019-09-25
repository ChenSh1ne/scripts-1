#!/bin/bash

#PBS -d .
#PBS -l mem=8gb,walltime=48:00:00,nodes=1:ppn=14
#PBS -e error/${S}.tmm.err
#PBS -o output/${S}.tmm.out

##########################################################################
#                                                                        #
# --- Must specify: A - nextera or illumina, for adapters                #
#                   R - basename of reference genome fasta / bt2 index   #
#                   S - basename of sample files                         #
#                                                                        #
##########################################################################

module purge
module load gcc/6.2.0 python/3.6.0 pigz 
mkdir -p trimmed_fastqs final_fastqs bams 

export PATH=$PATH:/home/nvankuren/.local/bin:/gpfs/data/kronforst-lab/nvankuren/programs/bin

# get read group information for later
header=`gunzip -c final_fastqs/${S}.r1.fq.gz | head -n 1`
rgpu=`echo "$header" | cut -f3,4,10 -d ":"`
rgid=$rgpu
rgsm=`echo $header | cut -f 1 -d "."`
rglb=`echo $header | cut -f 1,2 -d "."`
rgpl=illumina

# trim adapters
trim_galore --paired --quality 20 --phred33 --${A} \
	    --length 36 --trim-n --output_dir trimmed_fastqs/ \
	    --basename $S --cores 4 \
	    --path_to_cutadapt=/home/nvankuren/.local/bin/cutadapt \
	    raw_fastqs/${S}.r1.fq.gz raw_fastqs/${S}.r2.fq.gz

# get rid of overrepresented sequences
module load java-jdk/1.8.0_92 fastqc python/2.7.13 samtools

fastqc --extract trimmed_fastqs/${S}_R[12]_val_[12].fq.gz

RemoveFastqcOverrepSequenceReads.py \
    --left_reads trimmed_fastqs/${S}_R1_val_1.fq.gz \
    --right_reads trimmed_fastqs/${S}_R2_val_2.fq.gz \
    --fastqc_left trimmed_fastqs/${S}_R1_val_1_fastqc/fastqc_data.txt \
    --fastqc_right trimmed_fastqs/${S}_R2_val_2_fastqc/fastqc_data.txt

gzip -c ${S}_R1_val_1.fq.or > final_fastqs/${S}.r1.fq.gz
gzip -c ${S}_R2_val_2.fq.or > final_fastqs/${S}.r2.fq.gz

rm ${S}_R*.fq.or

# map to the reference genome
module load bowtie2

bowtie2 --threads 14 --very-sensitive-local \
	--rg-id $rgid \
	--rg "PL:${rgpl}" \
	--rg "SM:${rgsm}" \
	--rg "LB:${rglb}" \
	--rg "PU:${rgpu}" \
	-x ../reference/${R} \
	-1 final_fastqs/${S}.r1.fq.gz \
	-2 final_fastqs/${S}.r2.fq.gz | \
    samtools view -bS - > bams/${S}.raw.bam

samtools sort --threads 14 -m 450M -o bams/${S}.sort.bam bams/${S}.raw.bam
samtools index bams/${S}.sort.bam

# Check if completed
if [ -f bams/${S}.sort.bam.bai ]; then
    rm bams/${S}.raw.bam
else
    echo "FAILED AT RAW BAM SORTING STEP"
    exit
fi

# Mark duplicates
java -Xmx8g -jar /apps/software/java-jdk-1.8.0_92/picard/2.8.1/picard.jar MarkDuplicates \
     I=bams/${S}.sort.bam \
     O=bams/${S}.md.bam \
     M=output/${S}.metrics 

samtools index bams/${S}.md.bam

# Check if completed successfully
if [ -f bams/${S}.md.bam.bai ]; then
    rm bams/${S}.sort.ba*
else
    echo "FAILED AT MARKDUPLICATES"
    exit
fi

# Indel Realignment
G=/apps/software/java-jdk-1.8.0_92/gatk/3.8/GenomeAnalysisTK.jar

java -Xmx8g -jar $G -T RealignerTargetCreator \
     -nt 16 \
     -R ../reference/${R}.fa \
     -I bams/${S}.md.bam \
     -o bams/${S}.intervals

java -Xmx8g -jar $G -T IndelRealigner \
     -R ../reference/${R}.fa \
     -I bams/${S}.md.bam \
     --targetIntervals bams/${S}.intervals \
     --out bams/${S}.realigned.bam 

if [ -f bams/${S}.realigned.bai ]; then
    rm bams/${S}.md.ba*
    rm bams/${S}.intervals
else
    echo "FAILED AT REALIGNMENT STEP"
    exit
fi

samtools flagstat bams/${S}.realigned.bam > bams/${S}.flagstat
