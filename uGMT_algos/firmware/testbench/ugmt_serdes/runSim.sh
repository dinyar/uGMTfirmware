#!/bin/bash

make && vsim -c -t 1ps testbench -do ugmt_serdes_tb.do
