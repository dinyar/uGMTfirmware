#!/bin/bash
warning() {
    scriptname=$(basename $BASH_SOURCE)
    echo "Implementation script example"
    echo "=========================="
    echo "In order to run the implementation on your system, ${scriptname} must be customized to your setup."
    echo "Comment the line containing 'warning' in ${scriptname} to remove this message."
}

# Comment this line after customizing the environment
warning && exit 1

# Check for Xilinx environment
if [ -z "$XILINX" ]; then
    echo "No Xilinx, no party"
    exit 1
fi

## CUSTOMIZE THESE VARIABLES
WORKING_DIR=/home/scratch/xilinx_results # Directory can become large (O(10 GB)).
HOSTS_FILE=/home/scratch/smartxplorer_hosts_local
STRATEGIES_FILE=/home/scratch/smartxplorer_custom-strategies
NO_RUNS=14 # Number of smartxplorer runs
## END OF CUSTOMIZATION

xtclsh uGMT.tcl

if [ $? -eq 0 ]
then
    smartxplorer -p xc7vx690t-2-ffg1927 -l $HOSTS_FILE -m $NO_RUNS -uc "../cactusupgrades/boards/mp7/base_fw/common/firmware/ucf/area_constraints.ucf;../cactusupgrades/boards/mp7/base_fw/common/firmware/ucf/clock_constraints.ucf;../cactusupgrades/boards/mp7/base_fw/common/firmware/ucf/mp7_pins.ucf;../cactusupgrades/boards/mp7/base_fw/mp7_690es/firmware/ucf/mp7.ucf;../cactusupgrades/components/uGMT_algos/firmware/ucf/algo_constraints.ucf" -wd $WORKING_DIR -rcmd ssh top.ngd
    ## Uncomment the following (and comment the above smartxplorer call) if the custom strategy file should be used)
    # smartxplorer -p xc7vx690t-2-ffg1927 -l $HOSTS_FILE -m $NO_RUNS -sf $STRATEGIES_FILE -uc "../cactusupgrades/boards/mp7/base_fw/common/firmware/ucf/area_constraints.ucf;../cactusupgrades/boards/mp7/base_fw/common/firmware/ucf/clock_constraints.ucf;../cactusupgrades/boards/mp7/base_fw/common/firmware/ucf/mp7_pins.ucf;../cactusupgrades/boards/mp7/base_fw/mp7_690es/firmware/ucf/mp7.ucf;../cactusupgrades/components/uGMT_algos/firmware/ucf/algo_constraints.ucf" -wd $WORKING_DIR -rcmd ssh top.ngd
fi
