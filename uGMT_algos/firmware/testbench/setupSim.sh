#!/bin/bash

if [ $# -lt 1 ];
then
    echo "Error, expecting path to testbench."
    exit
fi

mp7fw_repo_subdir=tags/mp7/stable/firmware/mp7fw_v2_2_1
if [ ! $# == 2 ];
then
    echo "mp7fw release not given. Setting to "$mp7fw_repo_subdir"."
else
    mp7fw_repo_subdir=$2
fi

# Get test and LUT files
bash update_testfiles.sh $mp7fw_repo_subdir

# Create the simulation
cd $1
bash buildSim.sh
