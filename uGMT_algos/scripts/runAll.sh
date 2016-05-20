#!/bin/bash
export XILINXD_LICENSE_FILE='2112@lxlicen01,2112@lxlicen02,2112@lxlicen03'
# Set up CACTUS environment
export LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
export PATH=/opt/cactus/bin:/opt/cactus/bin/uhal/tools:$PATH

source /home/scratch/Vivado2016.1/Vivado/2016.1/settings64.sh

PROJECTFILE="top/top.xpr"

##### Create files #####
cat << EOM > setupSynthesis.tcl
open_project $PROJECTFILE
launch_runs synth_1 -scripts_only
exit
EOM

cat << EOM > setupImplementation.tcl
open_project $PROJECTFILE
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
launch_runs impl_1 -scripts_only
exit
EOM

cat << EOM > makeBitfile.tcl
open_project $PROJECTFILE
launch_runs impl_1 -to_step write_bitstream -scripts_only
exit
EOM

## Reset project and run steps up to bitfile generation and packaging.
make reset
vivado -mode batch -source setupSynthesis.tcl
bash -ex top/top.runs/synth_1/runme.sh
vivado -mode batch -source setupImplementation.tcl
bash -ex top/top.runs/impl_1/runme.sh
vivado -mode batch -source makeBitfile.tcl
bash -ex top/top.runs/impl_1/runme.sh

python checkTiming.py

make package
