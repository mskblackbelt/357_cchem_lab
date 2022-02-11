#!/bin/bash

# A simple script to populate directory tree with 
# instances of input.temp file with substituted DIST variable

# Created by MM / NYC Feb 2019

# Ensure all commands begin in he directory containing the script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Run rough scan by 1 angstrom first
for d in `seq -f "%3.2f" 0.7 0.1 1.3`
do 
	echo "running position " $d
	mkdir -p dist_$d 
	sed -e "s/DIST/$d/g" input.temp > dist_$d/input.com 
	cd dist_$d
	g16 input.com > input.log
	cd ../
done

# Run fine scan near where we know the minimum to be
for d in `seq -f "%3.2f" 0.85 0.02 0.95`
do 
	echo "running position " $d
	mkdir -p dist_$d 
	sed -e "s/DIST/$d/g" input.temp > dist_$d/input.com 
	cd dist_$d
	g16 input.com > input.log
	cd ../
done

# Output all values to file
printf "%5s%12s\n" dist "E[Ha]" > dist_E.dat

for i in dist_[01]* 
	do 
	d=`echo $i | awk -F"_" '{print $2}'`
	E=`grep "Done" $i/input.log | awk '{printf "%20.8f", $5}'`
        printf "%5.2f%20.8f\n" $d $E >> dist_E.dat 

done



