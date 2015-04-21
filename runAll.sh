#!/bin/bash
export XILINXD_LICENSE_FILE='2112@lxlic01,2112@lxlic02,2112@lxlic03'
# Set up CACTUS environment
export LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
export PATH=/opt/cactus/bin:/opt/cactus/bin/uhal/tools:$PATH

source /home/scratch/Xilinx/Vivado/2014.4/settings64.sh

PROJECTFILE="top/top.xpr"

##### Create files #####
cat << EOM > setupSynthesis.tcl
open_project $PROJECTFILE
launch_runs synth_1 -scripts_only
exit
EOM

cat << EOM > setupImplementation.tcl
open_project $PROJECTFILE
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.TCL.POST "$(pwd)/stopBuildIfFailedTiming.tcl" [get_runs impl_1]
launch_runs impl_1 -scripts_only
exit
EOM

cat << EOM > makeBitfile.tcl
open_project $PROJECTFILE
launch_runs impl_1 -to_step write_bitstream
exit
EOM

cat << EOM > stopBuildIfFailedTiming.tcl
# Halt the flow with an error if the timing constraints weren't met

set minireport [report_timing_summary -no_header -no_detailed_paths -return_string]

if {! [string match -nocase {*timing constraints are met*} $minireport]} {
    send_msg_id showstopper-0 error "Timing constraints weren't met. Please check your design."
    return -code error
}
EOM

## Reset project and run steps up to bitfile generation and packaging.
make reset
vivado -mode batch -source setupSynthesis.tcl
bash -ex top/top.runs/synth_1/runme.sh
vivado -mode batch -source setupImplementation.tcl
bash -ex top/top.runs/impl_1/runme.sh
vivado -mode batch -source makeBitfile.tcl

make package

