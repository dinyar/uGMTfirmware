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
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/deserializer_fwd_iso_scan.txt --no-check-certificate
if [ -f deserializer_fwd_iso_scan.txt.1 ];
then
	mv deserializer_fwd_iso_scan.txt.1 deserializer_fwd_iso_scan.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/deserializer_ttbar_small_sample.txt --no-check-certificate
if [ -f deserializer_ttbar_small_sample.txt.1 ];
then
	mv deserializer_ttbar_small_sample.txt.1 deserializer_ttbar_small_sample.txt
fi
