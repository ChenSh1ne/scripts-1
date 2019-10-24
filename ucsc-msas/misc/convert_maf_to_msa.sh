#!/bin/bash

# Set up directory structure

mkdir splitMafs intermediate_fastas outgroup_fastas

# Split multiz outpuf MAF

mafSplit /dev/null splitMafs/ NEW.maf -byTarget -useFullSequenceName

# Convert split MAF files into multi-fasta files

for maf in `ls splitMafs/ | cut -f 1 -d "."`
    do
        msa_view --refseq ../genomes/dmel/${maf}.fa --gap-strip 1 --unmask --soft-masked \
		 --in-format MAF --out-format FASTA splitMafs/${maf}.maf | \
	    sed 's/> />/g;s/*/-/g' > intermediate_fastas/${maf}.mfa

	faSplit byname intermediate_fastas/${maf}.mfa intermediate_fastas/

	for sp in dmel dsim dsec dere dyak
	    do
		if [ -f intermediate_fastas/${sp}.fa ]; then
		
		    sed "s/$sp/$maf/" intermediate_fastas/${sp}.fa >> outgroup_fastas/${sp}.fasta
		    rm intermediate_fastas/${sp}.fa
		    
		fi
	done

done
