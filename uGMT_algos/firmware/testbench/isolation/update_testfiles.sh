#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/many_events.txt --no-check-certificate
if [ -f many_events.txt.1 ];
then
	mv many_events.txt.1 many_events.txt
fi

