for l in {4..4}
do
    for i in {6..6}
    do
	for j in {2..4}
	do
	    for k in {0..0}
	    do
		let m=$(($i + $j))
		echo "mn: $l, lowdeg: $i, highdeg: $m, numterms: $k"
		printf "load \"classSort_rev1.6.5.m2\"\nmain(40000,mn=>%d, lowDeg=>%d, highDeg=>%d, numTerms=>%d, checkIn=>1000, maxTries=>20, useN=>false, logging=>false)" $l $i $m $k > tmp.m2
		M2 --script "tmp.m2"
		
	    done

	done

    done
done

for l in {5..6}
do
    for i in {2..6}
    do
	for j in {0..4}
	do
	    for k in {0..0}
	    do
		let m=$(($i + $j))
		echo "mn: $l, lowdeg: $i, highdeg: $m, numterms: $k"
		printf "load \"classSort_rev1.6.5.m2\"\nmain(40000,mn=>%d, lowDeg=>%d, highDeg=>%d, numTerms=>%d, checkIn=>1000, maxTries=>20, useN=>false, logging=>false)" $l $i $m $k > tmp.m2
		M2 --script "tmp.m2"
		
	    done

	done

    done
done
				    
