#!/bin/bash

if [ $# -lt 1 ];
then
    echo "Error, expecting mp7fw release path."
    exit
fi
mp7fw_repo_subdir=$1

if [ ! -d patterns ];
then
    mkdir patterns
fi

# Get the test patterns
python ../../scripts/get_testpatterns.py testbench --outpath patterns/.

# Update the LUT content files.
python ../../scripts/get_luts.py binary --outpath ../hdl/ipbus_slaves/.

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
