#!/bin/bash

echo "usage: bash ConvertMafToOrdered.sh sp1 sp2"

sp1=$1
sp2=$2

module load UCSCtools

mafToPsl $sp2 $sp1 ${sp1}.${sp2}.net.maf ${sp1}.${sp2}.net.psl

perl getBestBlat.pl ${sp1}.${sp2}.net.psl ${sp1}.${sp2}.best

sort -k2,2 -k8,8n ${sp1}.${sp2}.best > ${sp2}_to_${sp1}.reordered

