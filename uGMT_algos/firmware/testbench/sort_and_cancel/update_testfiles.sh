#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/single_muons.txt --no-check-certificate
mv single_muons.txt.1 single_muons.txt
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/single_tfs.txt --no-check-certificate
mv single_tfs.txt.1 single_tfs.txt
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/sort_test.txt --no-check-certificate
mv sort_test.txt.1 sort_test.txt
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/many_events.txt --no-check-certificate
mv many_events.txt.1 many_events.txt
