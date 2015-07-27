#!/bin/bash

if [ $# -gt 0 ];
then
        testfile=$1
else
        testfile=many_events
fi

cd serializer
rm -f ugmt_testfile.dat
ln -s ../patterns/serializer_$testfile.txt ugmt_testfile.dat

cd ../sort_and_cancel
rm -f ugmt_testfile.dat
ln -s ../patterns/$testfile.txt ugmt_testfile.dat

cd ../ugmt_serdes
rm -f ugmt_testfile.dat
ln -s ../patterns/integration_$testfile.txt ugmt_testfile.dat

cd ..

