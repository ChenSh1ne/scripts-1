#!/bin/bash

D=`date +%Y%m%d`

#PBS -d .
#PBS -l mem=8gb,walltime=48:00:00,nodes=1:ppn=14
#PBS -e error/${S}.tmm.${C}.${D}.err
#PBS -o output/${S}.tmm.${C}.${D}.out

##########################################################################
#                                                                        #
# --- Must specify: A - nextera or illumina, for adapters                #
#                   R - basename of reference genome fasta / bt2 index   #
#                   S - basename of sample files                         #
#                   C - checkpoint: 0 (trim), 1 (overrep), 2 (mapping),  #
#                                   3 (sorting), 4 (MD), 5 (realignment) #
#                   M - which mapper to use: stampy|bowtie2              #
#                                                                        #
# Checkpoint is what step to start at.                                   #
#                                                                        #
# This script assumes that your fastqs are named ${S}.r[12].fq.gz and    #
# are located in ./raw_fastqs and that your reference genome is in       #
# ./reference/${R}.fa.                                                   #
#                                                                        #
#                                                                        #
# Ex.                                                                    #
#                                                                        #
# qsub -v S=sam1,R=hmel,A=illumina,C=0,M=bowtie2 -N sam1 TrimMapReads.sh #
#                                                                        #
##########################################################################

module purge
module load gcc/6.2.0
module load java-jdk/1.8.0_92
module load samtools

mkdir -p trimmed_fastqs final_fastqs bams 

# export PATH=$PATH:/home/nvankuren/.local/bin:/gpfs/data/kronforst-lab/nvankuren/programs/bin
export PATH=$PATH:/gpfs/data/kronforst-lab/share/programs/bin:/gpfs/data/kronforst-lab/share/programs/scripts

# get read group information for later. Simple.
rgpu=${S}.pu
rgid=$rgpu
rgsm=$S
rglb=$S
rgpl=illumina

# trim adapters

if [ "$C" -eq 0 ]; then

    echo "Starting trimming."

    module load python/3.6.0
    module load pigz
    
    trim_galore --paired --quality 20 --phred33 --${A} \
		--length 36 --trim-n --output_dir trimmed_fastqs/ \
		--basename $S --cores 4 \
		--path_to_cutadapt=/gpfs/data/kronforst-lab/share/programs/bin/cutadapt \
		raw_fastqs/${S}.r1.fq.gz raw_fastqs/${S}.r2.fq.gz

    echo "Finished trimming."

    module unload pigz python/3.6.0
    
fi

if [ "$C" -le 1 ]; then

    echo "Starting to remove overrepresented sequences."

    module load fastqc python/2.7.13
    
    fastqc --extract trimmed_fastqs/${S}_R[12]_val_[12].fq.gz
    
    RemoveFastqcOverrepSequenceReads.py \
	--left_reads trimmed_fastqs/${S}_R1_val_1.fq.gz \
	--right_reads trimmed_fastqs/${S}_R2_val_2.fq.gz \
	--fastqc_left trimmed_fastqs/${S}_R1_val_1_fastqc/fastqc_data.txt \
	--fastqc_right trimmed_fastqs/${S}_R2_val_2_fastqc/fastqc_data.txt

    gzip -c ${S}_R1_val_1.fq.or > final_fastqs/${S}.r1.fq.gz 
    gzip -c ${S}_R2_val_2.fq.or > final_fastqs/${S}.r2.fq.gz
	 
    rm ${S}_R*.fq.or

    if [ -f final_fastqs/${S}.r2.fq.gz ]; then
	rm raw_fastqs/${S}.r[12].fq.gz
	rm -r trimmed_fastqs/${S}.r[12].*
    fi

    module unload fastqc python/2.7.13
    
fi


# map to the reference genome
if [ "$C" -le 2 ]; then

    if [ "$M" = "stampy" ]; then

	module load python/2.7.13

	if [ ! -f reference/${R}.stidx ]; then

	    echo "Building stampy index and hash."
	    python /apps/software/gcc-6.2.0/stampy/1.0.31/stampy.py \
		   -G reference/${R} reference/${R}.fa

	    python /apps/software/gcc-6.2.0/stampy/1.0.31/stampy.py \
		   -g reference/${R} -H reference/${R}

	    echo "Finished building stampy index and hash."

	fi
	    
	echo "Beginning to map with STAMPY."
	
	python /apps/software/gcc-6.2.0/stampy/1.0.31/stampy.py \
	       -g reference/${R} \
	       -h reference/${R} \
	       --readgroup=ID:${S},LB:${S},PL:illumina,SM:${S} \
	       -t 16 \
	       --substitutionrate=0.0001 \
	       -M final_fastqs/${S}.r1.fq.gz final_fastqs/${S}.r2.fq.gz | \
	    samtools view -bS - > bams/${S}.raw.bam

    else
	
	module load bowtie2

	# Build indexes if necessary
	if [ ! -f reference/${R}.1.bt2 ]; then
	    echo "Building reference indexes..."
	    bowtie2-build --threads 16 reference/${R}.fa reference/${R}
	    echo "Done."
	fi
	
	# Build dictionary if necessary
	if [ ! -f reference/${R}.dict ]; then
	    echo "Building sequence dictionary..."

	    java -jar /apps/software/java-jdk-1.8.0_92/picard/2.8.1/picard.jar CreateSequenceDictionary R=reference/${R}.fa
	    echo "Done."
	fi
	
	echo "Beginning to map with BOWTIE2."
	bowtie2 --threads 14 --very-sensitive-local \
		--rg-id $rgid \
		--rg "PL:${rgpl}" \
		--rg "SM:${rgsm}" \
		--rg "LB:${rglb}" \
		--rg "PU:${rgpu}" \
		-x reference/${R} \
		-1 final_fastqs/${S}.r1.fq.gz \
		-2 final_fastqs/${S}.r2.fq.gz | \
	    samtools view -bS - > bams/${S}.raw.bam
	
	echo "Done mapping with bowtie."

	module unload bowtie2
	
    fi
    
fi

# sort the bam
if [ "$C" -le 3 ]; then

    echo "Beginning to sort."
    samtools sort --threads 14 -m 450M -o bams/${S}.sort.bam bams/${S}.raw.bam
    samtools index bams/${S}.sort.bam

    # Check if completed
    if [ -f bams/${S}.sort.bam.bai ]; then
	echo "Finished sorting."
	rm bams/${S}.raw.bam
    else
	echo "FAILED AT RAW BAM SORTING STEP"
	exit
    fi

fi

# Mark duplicates
if [ "$C" -le 4 ]; then

    echo "Beginning to mark duplicates"
    java -Xmx8g -jar /apps/software/java-jdk-1.8.0_92/picard/2.8.1/picard.jar MarkDuplicates \
	 I=bams/${S}.sort.bam \
	 O=bams/${S}.md.bam \
	 M=output/${S}.metrics 

    samtools index bams/${S}.md.bam

    # Check if completed successfully
    if [ -f bams/${S}.md.bam.bai ]; then
	rm bams/${S}.sort.ba*
	echo "Finished marking duplicates."
    else
	echo "FAILED AT MARKDUPLICATES"
	exit
    fi
fi

# Indel Realignment
if [ "$C" -le 5 ]; then

    echo "Beginning to realign around indels."
    G=/apps/software/java-jdk-1.8.0_92/gatk/3.8/GenomeAnalysisTK.jar
    
    java -Xmx8g -jar $G -T RealignerTargetCreator \
	 -nt 16 \
	 -R reference/${R}.fa \
	 -I bams/${S}.md.bam \
	 -o bams/${S}.intervals
    
    java -Xmx8g -jar $G -T IndelRealigner \
	 -R reference/${R}.fa \
	 -I bams/${S}.md.bam \
	 --targetIntervals bams/${S}.intervals \
	 --out bams/${S}.realigned.bam 
    
    if [ -f bams/${S}.realigned.bai ]; then
	rm bams/${S}.md.ba*
	rm bams/${S}.intervals
	echo "Finished realignment."
    else
	echo "FAILED AT REALIGNMENT STEP"
	exit
    fi

    samtools flagstat bams/${S}.realigned.bam > bams/${S}.flagstat

fi
