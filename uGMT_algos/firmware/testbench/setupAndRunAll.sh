#!/bin/bash
export MODELSIM_ROOT='/opt/mentor/modeltech/'
## license server
export MGLS_LICENSE_FILE='1717@lxlic01:1717@lxlic02:1717@lxlic03'
PATH=$PATH:/opt/mentor/modeltech/linux_x86_64
export PATH

if [ ! -d results ];
then
	mkdir results
fi
cd deserializer
./configureSim.sh > /dev/null
./runSim.sh > /dev/null
cd ../GMT
./configureSim.sh > /dev/null
./runSim.sh > /dev/null
cd ../isolation
./configureSim.sh > /dev/null
./runSim.sh > /dev/null
cd ../serializer
./configureSim.sh > /dev/null
./runSim.sh > /dev/null
cd ../sort_and_cancel
./configureSim.sh > /dev/null
./runSim.sh > /dev/null
cd ../ugmt_serdes
./configureSim.sh > /dev/null
./runSim.sh > /dev/null
cd ..

python ../../../scripts/check_results.py
