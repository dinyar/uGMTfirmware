#!/bin/bash
export MODELSIM_ROOT='/opt/modelsim-104d/modeltech/'
## license server
export MGLS_LICENSE_FILE='1717@lxlic01:1717@lxlic02:1717@lxlic03'
PATH=$PATH:/opt/modelsim-104d/modeltech/linux_x86_64

mp7fw_repo_subdir=tags/mp7/stable/firmware/mp7fw_v2_2_1
if [ ! $# == 1 ];
then
    echo "mp7fw release not given. Setting to "$mp7fw_repo_subdir"."
else
    mp7fw_repo_subdir=$1
fi

echo "Updating test pattern and LUT content files.. "
bash update_testfiles.sh $mp7fw_repo_subdir

echo "Building serializer testbench.. "
cd serializer
./buildSim.sh

echo "Building SortAndCancel testbench.. "
cd ../sort_and_cancel
./buildSim.sh

echo "Building uGMTserdes testbench.. "
cd ../ugmt_serdes
./buildSim.sh

cd ..
