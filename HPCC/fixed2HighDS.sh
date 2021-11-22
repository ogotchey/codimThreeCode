#!/bin/bash
loop () 
{
    for a in {8..10}; do
    for (( b=8 ; b <= a ; b++ )) ; do
	for c in {2..4}; do
	    for d in {1..3}; do
		echo -e "load \"classSort_rev1.6.5.m2\"\nh = append(append(randomNonZero($c,$(($c+3)),$(($2-2))),$a),$b);\nmain(100000, mn=>$2, useN=>$1, degSeq=>h, numTerms=>$d, checkIn=>1000, workingDir=>\"fixed2HighDS/data/\");" > fixed2High.m2;
		M2 --script ./fixed2High.m2;
	    done;
	done;
    done;
    done;
}
for m in {6..12}; do
    loop "false" $m;
done;
for n in {3..10}; do
    loop "true" $n;
done;
    
