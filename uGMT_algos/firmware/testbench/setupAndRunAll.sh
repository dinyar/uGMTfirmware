#!/bin/bash
export MODELSIM_ROOT='/opt/mentor/modeltech/'
## license server
export MGLS_LICENSE_FILE='1717@lxlic01:1717@lxlic02:1717@lxlic03'
PATH=$PATH:/opt/mentor/modeltech/linux_x86_64
export PATH

if [ $# -gt 0 ];
then
	testfile=$1
else
	testfile=many_events
fi

if [ ! -d results ];
then
	mkdir results
else
	rm -f results/*
fi

echo "Updating test pattern and LUT content files.. "
bash update_testfiles.sh

echo "Running Serializer testbench.. "
cd serializer
./buildSim.sh
rm -f ugmt_testfile.dat
ln -s ../patterns/serializer_$testfile.txt ugmt_testfile.dat
./runSim.sh

echo "Running SortAndCancel testbench.. "
cd ../sort_and_cancel
./buildSim.sh
rm -f ugmt_testfile.dat
ln -s ../patterns/$testfile.txt ugmt_testfile.dat
./runSim.sh

echo "Running uGMTserdes testbench.. "
cd ../ugmt_serdes
./buildSim.sh
rm -f ugmt_testfile.dat
ln -s ../patterns/integration_$testfile.txt ugmt_testfile.dat
./runSim.sh

echo "Checking results.. "
cd ..
python ../../../scripts/check_results.py
