#!/bin/bash

#PBS -d .
#PBS -e error/${s1}_${s2}.preChainCat.err
#PBS -o output/${s1}_${s2}.preChainCat.out
#PBS -l mem=4gb,nodes=1:ppn=1,walltime=12:00:00

##Is first scaffold a RefSeq scaffold?
x=`ls psl/${s1}_${s2} | head -n 1 | cut -f 2 -d "."`
##Is second scaffold a RefSeq scaffold?
y=`ls psl/${s1}_${s2} | head -n 1 | awk '{if( $0 ~/\.1\.psl\.gz$/ ){ print 1 } else { print 0 }}'`


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

n=0
t=`ls psl/${s1}_${s2}/ | cut -f "$f" -d "." | sort | uniq | wc -l`

mkdir -p catted_psl/${s1}_${s2}

for i in `ls psl/${s1}_${s2}/ | cut -f "$f" -d "." | sort | uniq`; do

    find psl/${s1}_${s2}/ -name "*.${i}.psl.gz" -type f | xargs cat > catted_psl/${s1}_${s2}/${s1}.${i}.psl.gz
    if [ $(( $n % 100 )) == 0 ]; then echo "Finished $n $s2 scaffolds out of $t total"; fi
    (( n++ ))
    
done

rsync -a --delete for_deleting/ psl/${s1}_${s2}/
rm -r psl/${s1}_${s2}
mv catted_psl/${s1}_${s2} psl/${s1}_${s2}






