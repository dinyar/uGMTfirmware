#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/afs/cern.ch/work/d/dinyar/ugmt_firmware/mp7fw_current
#################################################

vlib sortAndCancel_tb
vmap work sortAndCancel_tb
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_package.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_sorting.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7_brd_decl.vhd
vcom -check_synthesis ../../hdl/Sorting/SorterUnit.vhd
vcom -check_synthesis ../../hdl/MatchAndMerge/*
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_dpram_dist.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_cancel_out_*.vhd
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit_spatialCoords.vhd
vcom -check_synthesis ../../hdl/GhostBusting/WedgeCheckerUnit.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_BO_WedgeComp.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_BO.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_FO_WedgeComp.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_FO.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_*
vcom -check_synthesis ../../hdl/common/comp10_ge_behavioral.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_countWins.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_Mux.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_behavioral.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/HalfSortStage0.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage1/SortStage1_behavioral.vhd
vcom -check_synthesis ../../hdl/Sorting/SortAndCancelUnit.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis SortAndCancelUnit_tb.vhd
vmake work > Makefile

ln -s ../../hdl/ipbus_slaves/BrlSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/OvlPosSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/OvlNegSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FwdPosSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FwdNegSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/BOPosMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/BONegMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FOPosMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FONegMatchQual.mif .

