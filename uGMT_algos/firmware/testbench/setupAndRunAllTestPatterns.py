#!/usr/bin/python

import os
import sys
import subprocess

testpatterns = ["TT_TuneCUETP8M1_13TeV", "JPsiToMuMu_Pt20to120_EtaPhiRestricted"]

error = 0
errorPatterns = []


subprocess.call(os.getcwd() + "/setupAll.sh")

for pattern in testpatterns:
    print "###############################################################################"
    print "Running " + pattern + " pattern:"
    subprocess.call([os.getcwd() + "/setTestfile.sh", pattern])
    tmpError = subprocess.call(os.getcwd() + "/runAll.sh")
    error += tmpError
    if tmpError != 0:
	errorPatterns.append(pattern)

if len(errorPatterns) > 0:
    print "Errors in:"
    for errorPattern in errorPatterns:
        print errorPattern

print error
sys.exit(error)

