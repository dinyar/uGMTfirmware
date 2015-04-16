#!/bin/bash

make && vsim -c -t 1ps testbench -do serializer_tb.do

echo "############################################################"
echo "WARNING: One error in the final BX is currently expected and will be fixed in the near future."
