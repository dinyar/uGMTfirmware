#!/bin/bash
export XILINXD_LICENSE_FILE='2112@lxlicen01,2112@lxlicen02,2112@lxlicen03'
# Set up CACTUS environment
export LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
export PATH=/opt/cactus/bin:/opt/cactus/bin/uhal/tools:$PATH

source /home/scratch/Vivado2016.1/Vivado/2016.1/settings64.sh

## Reset project and run steps up to bitfile generation and packaging.
make reset
make bitfile
python checkTiming.py

if [ "$?" == 0 ];
then
    echo "Timing met. Creating package.. "
else
    exit
fi

make package
