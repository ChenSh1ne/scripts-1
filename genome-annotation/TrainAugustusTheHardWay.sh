#!/bin/bash

. ~/.bashrc

N=$1
R=$2

mkdir -p augustus_training/${R}

# Convert the latest SNAP training hmm to genbank
perl $progs/Augustus/bin/zff2augustus_gbk.pl snap/${R}/export.ann snap/${R}/export.dna > augustus_training/${R}/${R}.gbk

# Split gbk into training and truth sets
perl $progs/Augustus/bin/randomSplit.pl augustus_training/${R}/${R}.gbk 100

# Create directory structure
perl $progs/Augustus/bin/new_species.pl --species=${N}_${R}

# Train
etraining --species=${N}_${R} augustus_training/${R}/${R}.gbk.train
augustus --species=${N}_${R} augustus_training/${R}/${R}.gbk.test | \
    tee augustus_training/${R}/${R}.trainingTest.out

perl $progs/Augustus/bin/optimize_augustus.pl --kfold=10 --cpus=10 --species=${N}_${R} augustus_training/${R}/${R}.gbk.train


