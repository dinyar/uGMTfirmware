#!/bin/bash
export XILINXD_LICENSE_FILE='2112@lxlicen01,2112@lxlicen02,2112@lxlicen03'
# Set up CACTUS environment
export LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
export PATH=/opt/cactus/bin:/opt/cactus/bin/uhal/tools:$PATH

source /home/scratch/Vivado2016.1/Vivado/2016.1/settings64.sh

PROJECTFILE="top/top.xpr"

##### Create files #####
cat << EOM > makeBitfile.tcl
open_project $PROJECTFILE
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE ExploreWithHoldFix [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
exit
EOM

## Reset project and run steps up to bitfile generation and packaging.
make reset
vivado -mode batch -source makeBitfile.tcl

python checkTiming.py

make package
