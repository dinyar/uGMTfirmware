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
bash setTestfile.sh $testfile

echo "Running setup.."
bash setupAll.sh

echo "Running testbenches.."
bash runAll.sh

