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
	testfile=TT_TuneCUETP8M1_13TeV
fi

if [ ! -d results ];
then
	mkdir results
else
	rm -f results/*
fi

echo "Running setup.."
bash setupAll.sh
bash setTestfile.sh $testfile

echo "Running testbenches.."
bash runAll.sh

