#!/bin/bash

if [ ! -d patterns ];
then
	mkdir patterns
fi

# Get the test patterns
python ../../scripts/get_testpatterns.py testbench --outpath patterns/.

# Update the LUT content files.
python ../../scripts/get_luts.py binary --outpath ../hdl/ipbus_slaves/.
