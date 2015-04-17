#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_many_events.txt --no-check-certificate
if [ -f serializer_many_events.txt.1 ];
then
	mv serializer_many_events.txt.1 serializer_many_events.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_iso_test.txt --no-check-certificate
if [ -f serializer_iso_test.txt.1 ];
then
	mv serializer_iso_test.txt.1 serializer_iso_test.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_fwd_iso_scan.txt --no-check-certificate
if [ -f serializer_fwd_iso_scan.txt.1 ];
then
	mv serializer_fwd_iso_scan.txt.1 serializer_fwd_iso_scan.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_ttbar_small_sample.txt --no-check-certificate
if [ -f serializer_ttbar_small_sample.txt.1 ];
then
	mv serializer_ttbar_small_sample.txt.1 serializer_ttbar_small_sample.txt
fi
