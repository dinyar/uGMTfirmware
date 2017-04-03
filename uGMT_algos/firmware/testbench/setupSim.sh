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
fi

# Get test and LUT files
bash update_testfiles.sh

# Get mp7fw
if [ ! -d "cactusupgrades" ]; then
    mkdir cactusupgrades
    pushd cactusupgrades
    mkdir -p boards/mp7
    pushd boards/mp7
    wget -O base_fw.zip https://svnweb.cern.ch/trac/cactus/browser/$MP7FW_REPO_SUBDIR/cactusupgrades/boards/mp7/base_fw?rev=HEAD\&format=zip
    unzip base_fw.zip
    rm -f base_fw.zip
    popd
    mkdir components
    pushd components
    wget -O ipbus_slaves.zip https://svnweb.cern.ch/trac/cactus/browser/$MP7FW_REPO_SUBDIR/cactusupgrades/components/ipbus_slaves?rev=HEAD\&format=zip
    unzip ipbus_slaves.zip
    rm -f ipbus_slaves.zip
    wget -O ipbus_core.zip https://svnweb.cern.ch/trac/cactus/browser/$MP7FW_REPO_SUBDIR/cactusupgrades/components/ipbus_core?rev=HEAD\&format=zip
    unzip ipbus_core.zip
    rm -f ipbus_core.zup
    wget -O mp7_datapath.zip https://svnweb.cern.ch/trac/cactus/browser/$MP7FW_REPO_SUBDIR/cactusupgrades/components/mp7_datapath?rev=HEAD\&format=zip
    unzip mp7_datapath.zip
    rm -f mp7_datapath.zip
    wget -O mp7_ttc.zip https://svnweb.cern.ch/trac/cactus/browser/$MP7FW_REPO_SUBDIR/cactusupgrades/components/mp7_ttc?rev=HEAD\&format=zip
    unzip mp7_ttc.zip
    rm -f mp7_ttc.zip
    popd
    popd
fi

# Create the simulation
cd $1
bash buildSim.sh
