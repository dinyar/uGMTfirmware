#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/home/scratch/vhdl/uGMT/vivado/prod/1.5.2/
#################################################

PATTERNFILE=ugmt_testfile.dat

vlib serializer_tb
vmap work serializer_tb
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis ../../hdl/serializer_stage.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis serializer_tb.vhd
vmake work > Makefile
bash update_testfiles.sh
echo "WARNING: Using serializer_many_events.txt pattern file. Modify $PATTERNFILE link if other pattern file required."
if [ -f $PATTERNFILE ];
then
    rm -f $PATTERNFILE
fi
ln -s serializer_many_events.txt $PATTERNFILE
