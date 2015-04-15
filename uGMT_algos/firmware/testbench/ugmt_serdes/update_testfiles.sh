#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/integration_many_events.txt --no-check-certificate
if [ -f integration_many_events.txt.1 ];
then
	mv integration_many_events.txt.1 integration_many_events.txt
fi
