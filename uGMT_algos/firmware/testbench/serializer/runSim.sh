#!/bin/bash

make && vsim -c -t 1ps testbench -do 'run -all'

echo "############################################################"
echo "WARNING: One error in the final BX is currently expected and will be fixed in the near future."
