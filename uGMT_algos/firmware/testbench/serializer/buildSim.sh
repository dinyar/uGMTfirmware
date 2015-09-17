#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/home/scratch/ugmt_firmware/mp7fw_current
#################################################

vlib serializer_tb
vmap work serializer_tb
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis ../../hdl/serializer_stage.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis serializer_tb.vhd

vmake work > Makefile

