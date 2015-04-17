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
echo "Running deserializer testbench.. "
cd deserializer
./setupSim.sh > /dev/null
./runSim.sh > /dev/null
echo "Running GMT testbench.. "
cd ../GMT
./setupSim.sh > /dev/null
./runSim.sh > /dev/null
echo "Running Isolation testbench.. "
cd ../isolation
./setupSim.sh > /dev/null
./runSim.sh > /dev/null
echo "Running Serializer testbench.. "
cd ../serializer
./setupSim.sh > /dev/null
# ./runSim.sh > /dev/null
echo "Running SortAndCancel testbench.. "
cd ../sort_and_cancel
./setupSim.sh > /dev/null
./runSim.sh > /dev/null
echo "Running uGMTserdes testbench.. "
cd ../ugmt_serdes
./setupSim.sh > /dev/null
./runSim.sh > /dev/null
cd ..

echo "Checking results.. "
python ../../../scripts/check_results.py