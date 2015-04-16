#!/bin/bash

make && vsim -c -t 1ps testbench -do isolation_tb.do
