#!/bin/bash

make && vsim -c -t 1ps testbench -do serializer_tb.do
