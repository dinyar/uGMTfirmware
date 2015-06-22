#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/afs/cern.ch/work/d/dinyar/ugmt_firmware/mp7fw_current
#################################################

PATTERNFILE=ugmt_testfile.dat

vlib deserializer_tb
vmap work deserializer_tb
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_package.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_deserialization.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_*_deserialization.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_v.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7_brd_decl.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/boards/mp7/base_fw/common/firmware/hdl/mp7_top_decl.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/projects/examples/mp7xe_690/firmware/hdl/top_decl.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_ttc/firmware/hdl/mp7_ttc_decl.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_counter.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_dpram.vhd
vcom -check_synthesis ../../hdl/deserializer_stages/deserialize_energy_quad.vhd
vcom -check_synthesis ../../hdl/deserializer_stages/deserialize_mu_quad.vhd
vcom -check_synthesis ../../hdl/deserializer_stages/deserializer_stage_energies.vhd
vcom -check_synthesis ../../hdl/deserializer_stages/deserializer_stage_muons.vhd
vcom -check_synthesis ../../hdl/deserializer_stages/gen_idx_bits.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis deserializer_tb.vhd

ln -s ../../hdl/ipbus_slaves/SortRank.mif .
vmake work > Makefile
echo "WARNING: Using deserializer_many_events.txt pattern file. Modify $PATTERNFILE link if other pattern file required."
if [ -f $PATTERNFILE ];
then
    rm -f $PATTERNFILE
fi
ln -s ../patterns/deserializer_many_events.txt $PATTERNFILE
