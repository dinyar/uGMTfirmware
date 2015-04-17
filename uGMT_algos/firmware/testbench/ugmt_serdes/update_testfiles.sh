#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/integration_many_events.txt --no-check-certificate
if [ -f integration_many_events.txt.1 ];
then
	mv integration_many_events.txt.1 integration_many_events.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/integration_iso_test.txt --no-check-certificate
if [ -f integration_iso_test.txt.1 ];
then
	mv integration_iso_test.txt.1 integration_iso_test.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/integration_fwd_iso_scan.txt --no-check-certificate
if [ -f integration_fwd_iso_scan.txt.1 ];
then
	mv integration_fwd_iso_scan.txt.1 integration_fwd_iso_scan.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/integration_ttbar_small_sample.txt --no-check-certificate
if [ -f integration_ttbar_small_sample.txt.1 ];
then
	mv integration_ttbar_small_sample.txt.1 integration_ttbar_small_sample.txt
fi
