#!/usr/bin/env bash

###################################################
#
# file: analysis.sh
#
# @Author:   Iacovos G. Kolokasis
# @Version:  07-03-2021
# @email:    kolokasis@ics.forth.gr
#
# Analysis of the executor log.
# Print size of all cached RDDs, average
# partitions sizes for each RDD, plot the access
# pattern of the RDDs.
#
###################################################

# Print error/usage script message
usage() {                                                                                                                                                                                      
    echo                                                                                                                                                                                       
    echo "Usage:"                                                                                                                                                                              
    echo -n "      $0 [option ...] "                                                                                                                                                           
    echo                                                                                                                                                                                       
    echo "Options:"                                                                                                                                                                            
    echo "      -p  Plot all RDDs in one graph"
    echo "      -i  Plot RDDs in individual graphs"
    echo "      -h  Show usage"
    echo                                                                                                                                                                                       

    exit 1
}

plot_all() {

	# Caclulate start time
	s_time=$(head -n 5 stderr \
		| tail -n 1 | grep [0-9]*:[0-9]*:[0-9]* \
		| awk '{print $2 }' \
		| awk -F ':' '{print (int($1) * 3600 + $2 * 60 + $3)}')

	# Parse all the files
	for f in $(ls |grep "rdd[0-9]*.out")
	do
		files+=( "-i $f" )
		legend+=( "-l $f" )
	done
	
	./plot_all.py \
		${files[@]} \
		-o $NAME.eps \
		${legend[@]} \
		-s $s_time

	epstopdf $NAME.eps
	pdfcrop $NAME.pdf

	rm $NAME.eps $NAME.pdf

	#mv $NAME-crop.pdf ../../../fig/analysis/cc/
}

plot() {
	for i in "${array[@]}"
	do
		echo $i
		./plot.py -i rdd$i.out -o rdd$i.eps
		epstopdf rdd$i.eps
		pdfcrop rdd$i.pdf
	done
}

report() {

	total_size=0
	for id in ${array[@]}
	do
		# Calculate total cached data size
		# GB
		total_size_gb=$(cat stderr | grep "estimated size" | grep -w "GB," | grep _${id}_ | awk '{sum+=$14} END {printf "%3.0f", sum}' | sed 's/,/./')
		# MB -> GB
		total_size_mb=$(cat stderr | grep "estimated size" | grep -w "MB," | grep _${id}_ | awk '{sum+=$14} END {printf "%3.0f", sum/1024}' | sed 's/,/./')
		# B -> GB
		total_size_b=$(cat stderr | grep "estimated size" | grep -w "B," | grep _${id}_ | awk '{sum+=$14} END {printf "%3.0f", sum/1024/1024/1024}' | sed 's/,/./')

		echo "$id | $total_size_gb | $total_size_mb | $total_size_b"

		total_size=$(echo "scale=2; $total_size + $total_size_gb + $total_size_mb + $total_size_b" | bc)

	done

	echo "====================="
	echo "REPORT"
	echo "====================="
	echo "TOTAL SIZE,$total_size GB"
	echo
	echo "RDD,TOTAL SIZE(GB),AVG SIZE(MB)"

	for id in ${array[@]}
	do
		size=$(cat stderr | grep "estimated size" | grep "MB" \
			|grep _${id}_ | awk '{sum+=$14} END {printf "%3.0f", sum/1024}' \
			| sed 's/,/./')

		avg=$(cat stderr | grep "estimated size" | grep "MB" \
			|grep _${id}_ | awk '{sum+=$14} END {printf "%3.0f", sum/NR}' \
			| sed 's/,/./')

		echo "$id,$size,$avg"
	done
	echo "====================="
}
                                                                                               
# Check for the input arguments                                                                
while getopts "n:rpih" opt
do                                                                                             
    case "${opt}" in                                                                           
        r)
            REPORT=true
            ;;                                                                                 

		p)
			PLOT_ALL=true
			;;
		i)
			PLOT=false
			;;
		n)
			NAME=${OPTARG}
			;;
        h)                                                                                                                                                                                     
            usage                                                                                                                                                                              
            ;;
        *)                 
            usage
            ;;
    esac
done

# Array with rdds
array=( $(cat stderr | grep "estimated size" | grep "B, \| MB, \| GB," \
	|grep "rdd_[0-9]*_0 " | awk '{print $6}' | awk -F '_' '{print $2}' | sort | uniq))

if [ $REPORT ]
then
	report
	exit
fi

if [ ! -f "rdd${array[0]}.out" ]
then
	echo ${array[0]}

	while read p; do

		echo "$p" > tmp

		time=$(grep [0-9]*:[0-9]*:[0-9]* tmp | awk '{print $2}' | awk -F ':' '{ print (int($1) * 3600 + int($2) * 60 + int($3))}')

		sed -i -e '0,/[0-9]*:[0-9]*:[0-9]*/ s/[0-9]*:[0-9]*:[0-9]*/'"$time"'/' tmp

		cat tmp >> file2.txt

	done < stderr

	for i in "${array[@]}"
	do
		echo $i
		cat file2.txt | grep rdd_$i > rdd$i.out
		sed -i '/\[rdd_/d' rdd$i.out
	done

	rm file2.txt tmp

fi

if [ "$PLOT_ALL" == "true" ]
then
	echo "HERE"
	plot_all
else
	plot
fi

#for i in "${array[@]}"
#do
#	rm rdd$i.out
#done
