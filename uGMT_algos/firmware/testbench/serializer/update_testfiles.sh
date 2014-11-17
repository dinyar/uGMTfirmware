#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_single_muons.txt --no-check-certificate
mv serializer_single_muons.txt.1 serializer_single_muons.txt
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_single_tfs.txt --no-check-certificate
mv serializer_single_tfs.txt.1 serializer_single_tfs.txt
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_sort_test.txt --no-check-certificate
mv serializer_sort_test.txt.1 serializer_sort_test.txt
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_many_events.txt --no-check-certificate
mv serializer_many_events.txt.1 serializer_many_events.txt
