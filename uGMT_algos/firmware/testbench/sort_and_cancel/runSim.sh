#!/bin/bash

make && vsim -c -t 1ps testbench -do SortAndCancel_tb.do
