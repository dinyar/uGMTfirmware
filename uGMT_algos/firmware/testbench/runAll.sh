#!/bin/bash
export MODELSIM_ROOT='/opt/modelsim-104d/modeltech/'
## license server
export MGLS_LICENSE_FILE='1717@lxlicen01,1717@lxlicen02,1717@lxlicen03;1717@lnxmics1;1717@lxlicen08'
PATH=$PATH:/opt/modelsim-104d/modeltech/linux_x86_64
export PATH

if [ ! -d results ];
then
	mkdir results
else
	rm -f results/*
fi
cd serializer
./runSim.sh &> /dev/null
cd ../sort_and_cancel
./runSim.sh &> /dev/null
cd ../ugmt_serdes
./runSim.sh &> /dev/null
cd ..

python ../../scripts/check_results.py
