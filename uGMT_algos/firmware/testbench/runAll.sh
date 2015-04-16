#!/bin/bash
if [ ! -d results ];
then
	mkdir results
fi
cd deserializer
./runSim.sh > /dev/null
cd ../GMT
./runSim.sh > /dev/null
cd ../isolation
./runSim.sh > /dev/null
cd ../serializer
./runSim.sh > /dev/null
cd ../sort_and_cancel
./runSim.sh > /dev/null
cd ../ugmt_serdes
./runSim.sh > /dev/null
cd ..
