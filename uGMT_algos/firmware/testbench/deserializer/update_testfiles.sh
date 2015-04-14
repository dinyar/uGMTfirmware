#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/deserializer_many_events.txt --no-check-certificate
if [ -f deserializer_many_events.txt.1 ];
then
	mv deserializer_many_events.txt.1 deserializer_many_events.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/deserializer_iso_test.txt --no-check-certificate
if [ -f deserializer_iso_test.txt.1 ];
then
	mv deserializer_iso_test.txt.1 deserializer_iso_test.txt
fi
