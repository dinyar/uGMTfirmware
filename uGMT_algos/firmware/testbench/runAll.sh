#!/bin/bash
export MODELSIM_ROOT='/opt/mentor/modeltech/'
## license server
export MGLS_LICENSE_FILE='1717@lxlic01:1717@lxlic02:1717@lxlic03'
PATH=$PATH:/opt/mentor/modeltech/linux_x86_64
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
