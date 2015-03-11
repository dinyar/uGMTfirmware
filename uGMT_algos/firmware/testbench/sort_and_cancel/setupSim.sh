#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/home/scratch/vhdl/uGMT/vivado/prod/1.5.2/
#################################################

PATTERNFILE=ugmt_testfile.dat

vlib sortAndCancel_tb
vmap work sortAndCancel_tb
vcom ../../cgn/mem_libs/blk/blk_mem_gen_v8_2.vhd
vcom -check_synthesis ../../cgn/mem_libs/dist/dist_mem_gen_v8_0.vhd
vcom -check_synthesis ../../cgn/mem_libs/dist/dist_mem_gen_v8_0_vh_rfs.vhd
vcom -check_synthesis ../../cgn/mem_libs/dist/dist_mem_gen_v8_0_vhsyn_rfs.vhd
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_package.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_sorting.vhd 
vcom -check_synthesis /home/scratch/vhdl/uGMT/vivado/prod/1.5.2/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd 
vcom -check_synthesis ../../hdl/Sorting/SorterUnit.vhd
vcom -check_synthesis ../../hdl/MatchAndMerge/*
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit.vhd
vcom -check_synthesis ../../cgn/cancel_out_mem.vhd
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit_spatialCoords.vhd 
vcom -check_synthesis ../../hdl/GhostBusting/WedgeCheckerUnit.vhd 
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_*
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_countWins.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_Mux.vhd 
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_behavioral.vhd 
vcom -check_synthesis ../../hdl/Sorting/Stage0/HalfSortStage0.vhd 
vcom -check_synthesis ../../hdl/Sorting/Stage1/SortStage1_behavioral.vhd 
vcom -check_synthesis ../../hdl/Sorting/SortAndCancelUnit.vhd 
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis SortAndCancelUnit_tb.vhd
vmake work > Makefile
bash update_testfiles.sh
echo "WARNING: Using many_events.txt pattern file. Modify $PATTERNFILE link if other pattern file required."
if [ -f $PATTERNFILE ];
then
    rm -f $PATTERNFILE
fi
ln -s many_events.txt $PATTERNFILE

