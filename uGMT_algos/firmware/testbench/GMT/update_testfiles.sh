#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/many_events.txt --no-check-certificate
if [ -f many_events.txt.1 ];
then
	mv many_events.txt.1 many_events.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/iso_test.txt --no-check-certificate
if [ -f iso_test.txt.1 ];
then
	mv iso_test.txt.1 iso_test.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/fwd_iso_scan.txt --no-check-certificate
if [ -f fwd_iso_scan.txt.1 ];
then
	mv fwd_iso_scan.txt.1 fwd_iso_scan.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/ttbar_small_sample.txt --no-check-certificate
if [ -f ttbar_small_sample.txt.1 ];
then
	mv ttbar_small_sample.txt.1 ttbar_small_sample.txt
fi
