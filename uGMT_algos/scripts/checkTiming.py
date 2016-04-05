#!/bin/python

if 'Router estimated timing not met.' in open('top/top.runs/impl_1/runme.log').read():
    print '\x1b[31;01m', '[CRITICAL ERROR] Timing closure was not achieved!', '\x1b[39;49;00m'
    exit(1)
else:
    exit(0)
