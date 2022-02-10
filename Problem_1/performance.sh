#!/bin/bash 

# The simple script creates a directory tree for METHODS/basis-set,
# creates an input file, and executes Gaussian. After job completion
# it collects the energies and number of basis functions into 
# the output file "performance.dat"

# Written By MM
# NYC Feb 2019

# Do all operations inside hte directory where script is run
cd "$(dirname "${BASH_SOURCE[0]}")"

printf "%10s%10s%10s%12s\n" Method basis-set "#BS" "E[Ha]" > performance.dat

for m in METHODS
do
  print
  for bs in STO-3G cc-pVDZ cc-pVTZ cc-pVQZ 
  do 
    # Create input files in separate folders for each method/basis
    mkdir -p $m/$bs
    cat <<EOF > $m/$bs/input.com

%nproc=2
%mem=400MB
# METHOD BS
# sp scf=tight 

test calculations for H 

0 2
H 0.0 0.0 0.0 

EOF
    sed -i "s/METHOD/$m/g" $m/$bs/input.com
    sed -i "s/BS/$bs/g"    $m/$bs/input.com 
    
    # Run each Gaussian file
    cd $m/$bs
    echo "Running :" $m "in" $bs "basis set"
    /usr/bin/g16/g16 input.com > input.log 
    
    #Find the energy and number of basis sets for each simulation
    E=`grep Done input.log | awk '{printf "%12.8f", $5}'` 
    nbs=`grep "basis functions, " input.log | awk '{printf "%5g", $1}'`
    
    # Return to base directory and add the data to the output file
    cd ../.. 
    printf "%10s%10s%10d%12.8f\n" $m $bs $nbs $E >> performance.dat
  done
done



