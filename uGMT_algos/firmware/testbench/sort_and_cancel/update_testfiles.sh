#!/bin/bash

wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/single_muons.txt --no-check-certificate
if [ -f single_muons.txt.1 ];
then
	mv single_muons.txt.1 single_muons.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/single_tfs.txt --no-check-certificate
if [ -f single_tfs.txt.1 ];
then
	mv single_tfs.txt.1 single_tfs.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/sort_test.txt --no-check-certificate
if [ -f sort_test.txt.1 ];
then
	mv sort_test.txt.1 sort_test.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/many_events.txt --no-check-certificate
if [ -f many_events.txt.1 ];
then
	mv many_events.txt.1 many_events.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/SingleMuPt100.txt --no-check-certificate
if [ -f SingleMuPt100.txt.1 ];
then
	mv SingleMuPt100.txt.1 SingleMuPt100.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/WM.txt --no-check-certificate
if [ -f WM.txt.1 ];
then
	mv WM.txt.1 WM.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/TTbar.txt --no-check-certificate
if [ -f TTbar.txt.1 ];
then
	mv TTbar.txt.1 TTbar.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/ZMM.txt --no-check-certificate
if [ -f ZMM.txt.1 ];
then
	mv ZMM.txt.1 ZMM.txt
fi
wget https://github.com/jlingema/uGMTScripts/raw/master/ugmt_patterns/data/patterns/testbench/FakeMuons.txt --no-check-certificate
if [ -f FakeMuons.txt.1 ];
then
	mv FakeMuons.txt.1 FakeMuons.txt
fi

