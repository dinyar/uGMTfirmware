#!/bin/bash

if [ ! $# == 1 ];
then
	echo "Error, expecting path to testbench."
	exit
fi

# Get test and LUT files
bash update_testfiles.sh

exit

# Create the simulation
cd $1
bash buildSim.sh
