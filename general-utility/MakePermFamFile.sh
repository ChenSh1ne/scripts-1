#!/bin/bash

# Get the main sample names and sex, fam, etc. Change
# the fam filename here to whatever you have it called.
# Alternatively, make a copy of the bfile set and call
# it ForPermutations so that you effectively back up
# your original data.
cut -f 1-5 -d " " ForPermutations.fam_original > body

# Get the phenotype pairs
cut -f 6,7 -d " " ForPermutations.fam_original > phenos

# Initialize a with a shuffled set of phenotype pairs
shuf phenos > a;

# Do 999 more.
for i in {1..999}; do
    
    shuf phenos | paste -d " " a - > b; mv b a;

done

# Paste the body and shuffled phenotypes together.
# Before running the submission script, you must rename
# this permuted fam file to be just the bfile_root.fam.
paste -d " " body a > ForPermutations.fam_permuted

# Clean up
rm a phenos body;

