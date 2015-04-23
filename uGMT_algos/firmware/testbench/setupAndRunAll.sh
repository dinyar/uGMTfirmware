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
fi

echo "Updating test pattern and LUT content files.. "
bash update_testfiles.sh

echo "Running deserializer testbench.. "
cd deserializer
./buildSim.sh &> /dev/null
rm -f ugmt_testfile.dat
ln -s ../patterns/deserializer_$testfile.txt ugmt_testfile.dat
./runSim.sh &> /dev/null

echo "Running GMT testbench.. "
cd ../GMT
./buildSim.sh &> /dev/null
rm -f ugmt_testfile.dat
ln -s ../patterns/$testfile.txt ugmt_testfile.dat
./runSim.sh &> /dev/null

echo "Running Isolation testbench.. "
cd ../isolation
./buildSim.sh &> /dev/null
rm -f ugmt_testfile.dat
ln -s ../patterns/$testfile.txt ugmt_testfile.dat
./runSim.sh &> /dev/null

echo "Running Serializer testbench.. "
cd ../serializer
./buildSim.sh &> /dev/null
rm -f ugmt_testfile.dat
ln -s ../patterns/serializer_$testfile.txt ugmt_testfile.dat
./runSim.sh &> /dev/null

echo "Running SortAndCancel testbench.. "
cd ../sort_and_cancel
./buildSim.sh &> /dev/null
rm -f ugmt_testfile.dat
ln -s ../patterns/$testfile.txt ugmt_testfile.dat
./runSim.sh &> /dev/null

echo "Running uGMTserdes testbench.. "
cd ../ugmt_serdes
./buildSim.sh &> /dev/null
rm -f ugmt_testfile.dat
ln -s ../patterns/integration_$testfile.txt ugmt_testfile.dat
./runSim.sh &> /dev/null

echo "Checking results.. "
cd ..
python ../../../scripts/check_results.py
