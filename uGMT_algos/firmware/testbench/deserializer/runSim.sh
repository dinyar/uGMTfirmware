#!/bin/bash

make && vsim -c -t 1ps testbench -do deserializer_tb.do
