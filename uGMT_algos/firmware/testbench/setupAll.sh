#!/bin/bash
export MODELSIM_ROOT='/opt/mentor/modeltech/'
## license server
export MGLS_LICENSE_FILE='1717@lxlic01:1717@lxlic02:1717@lxlic03'
PATH=$PATH:/opt/mentor/modeltech/linux_x86_64
export PATH


bash update_testfiles.sh

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

