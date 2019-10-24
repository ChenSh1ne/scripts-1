s1=$1
s2=$2

tot=`ls cluster_scripts/${s1}_${s2}/ | tail -n 1 | awk -v FS="_" '{print $NF}' | sed 's/^0*//'`

i=0
n=0

if [ $tot -le 300 ]; then
    echo "qsub -t 0-${tot} -N ${s1}_${s2}_set${n} -v ${s1}_${s2} array_wrapper.sh"
else
    

    while [ $(( i + 299 )) -le $tot ]; do

	e=$(( i + 299 ))	    

	qsub -t ${i}-${e} -N ${s1}_${s2}_set${n} -v S=${s1}_${s2} array_wrapper.sh
	sleep 15;
	echo "finished set $n"
	
	i=$(( e + 1 ))
	(( n++ ))
	
    done

    # Last one

    qsub -t ${i}-${tot} -N ${s1}_${s2}_set${n} -v S=${s1}_${s2} array_wrapper.sh
fi
