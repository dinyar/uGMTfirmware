#!/bin/bash

rm -rf serializer_tb

vlib serializer_tb
vmap work serializer_tb
vcom -check_synthesis ../cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis ../cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7_brd_decl.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis ../../hdl/serialize_outputs_quad.vhd
vcom -check_synthesis ../../hdl/serializer_stage.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis serializer_tb.vhd

vmake work > Makefile
