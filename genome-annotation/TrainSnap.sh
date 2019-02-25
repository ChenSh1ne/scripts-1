#!/bin/bash

. ~/.bashrc

R=$1
N=$2

mkdir -p snap/${R}
cd snap/${R}

# export 'confident' gene models from MAKER and rename to something meaningful
maker2zff -x 0.25 -l 50 -d ../../${N}.maker.output/${N}_master_datastore_index.log
rename genome. ${R}. genome.*

# gather some stats and validate
fathom ${R}.ann ${R}.dna -gene-stats > ${R}.gene-stats.log 2>&1
fathom ${R}.ann ${R}.dna -validate > ${R}.validate.log 2>&1

# collect the training sequences and annotations, plus 1000 surrounding bp for training
fathom ${R}.ann ${R}.dna -categorize 1000 > ${R}.categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > ${R}.uni-plus.log 2>&1

# create the training parameters
mkdir params
cd params
forge ../export.ann ../export.dna > ../${R}.forge.log 2>&1
cd ..

# assembly the HMM. the hmm is in, e.g. snap/round1/
perl $progs/snap/hmm-assembler.pl $R params > ${R}.hmm
