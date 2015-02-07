#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_single_muons.txt --no-check-certificate
if [ -f "serializer_single_muons.txt.1" ];
then
    mv serializer_single_muons.txt.1 serializer_single_muons.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_single_tfs.txt --no-check-certificate
if [ -f "serializer_single_tfs.txt.1" ];
then
    mv serializer_single_tfs.txt.1 serializer_single_tfs.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_sort_test.txt --no-check-certificate
if [ -f "serializer_sort_test.txt.1" ];
then
    mv serializer_sort_test.txt.1 serializer_sort_test.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_many_events.txt --no-check-certificate
if [ -f "serializer_many_events.txt.1" ];
then
    mv serializer_many_events.txt.1 serializer_many_events.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_SingleMuPt100.txt --no-check-certificate
if [ -f "serializer_SingleMuPt100.txt.1" ];
then
    mv serializer_SingleMuPt100.txt.1 serializer_SingleMuPt100.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_ZMM.txt --no-check-certificate
if [ -f "serializer_ZMM.txt.1" ];
then
    mv serializer_ZMM.txt.1 serializer_ZMM.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_WM.txt --no-check-certificate
if [ -f "serializer_WM.txt.1" ];
then
    mv serializer_WM.txt.1 serializer_WM.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_FakeMuons.txt --no-check-certificate
if [ -f "serializer_FakeMuons.txt.1" ];
then
    mv serializer_FakeMuons.txt.1 serializer_FakeMuons.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_MinBias.txt --no-check-certificate
if [ -f "serializer_MinBias.txt.1" ];
then
    mv serializer_MinBias.txt.1 serializer_MinBias.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/serializer_TTbar.txt --no-check-certificate
if [ -f "serializer_TTbar.txt.1" ];
then
    mv serializer_TTbar.txt.1 serializer_TTbar.txt
fi

