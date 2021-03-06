#!/bin/bash

#PBS -d .
#PBS -e error/${s1}_${s2}.step4.err
#PBS -o output/${s1}_${s2}.step4.out
#PBS -l mem=60gb,nodes=1:ppn=3,walltime=96:00:00

. ~/.bashrc

module load UCSCtools

n=0;

##Execute from project directory
if [ ! -d "chain/${s1}_${s2}" ]; then mkdir chain/${s1}_${s2}; fi

##Is first scaffold a RefSeq scaffold?
x=`ls psl/${s1}_${s2} | head -n 1 | cut -f 2 -d "."`
echo -e "x is $x"
##Is second scaffold a RefSeq scaffold?
y=`ls psl/${s1}_${s2} | head -n 1 | awk '{if( $0 ~/\.1\.psl\.gz$/ ){ print 1 } else { print 0 }}'`
echo -e "y is $y"


if [ $x -eq 1 ]; then
    if [ $y -eq 1 ]; then
	f="3,4"
    else
	f=3
    fi   
else
    if [ $y -eq 1 ]; then
	f="2,3"
    else
	f=2
    fi
fi

echo -e "f is $f"

for i in `ls psl/${s1}_${s2} | cut -f "$f" -d "." | sort | uniq`; do


    if [ ! -f "chain/${s1}_${s2}/${i}.chain" ]; then
	
    gunzip -c psl/${s1}_${s2}/*.${i}.psl.gz | axtChain -psl -verbose=0 -linearGap=medium \
    stdin genomes/${s1}/${s1}.2bit genomes/${s2}/${s2}.2bit stdout | chainAntiRepeat \
    genomes/${s1}/${s1}.2bit genomes/${s2}/${s2}.2bit stdin chain/${s1}_${s2}/${i}.chain

    fi
    
    if [ $(( $n % 100 )) == 0 ]; then echo "Finished $n $s2 scaffolds"; fi
    (( n++ ))
    
done

find chain/${s1}_${s2}/ -name "*.chain" | chainMergeSort -inputList=stdin > chain/${s1}.${s2}.all.chain   


