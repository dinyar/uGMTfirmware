#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/home/scratch/vhdl/uGMT/vivado/prod/1.5.2/
#################################################

PATTERNFILE=ugmt_testfile.dat

vlib ugmt_serdes
vmap work ugmt_serdes
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_package.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_sorting.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_sort_rank_mems.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_deserialization.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_v.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_dpram_dist.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_dpram.vhd
vcom -check_synthesis ../../hdl/deserialize_energy_quad.vhd
vcom -check_synthesis ../../hdl/deserialize_mu_quad.vhd
vcom -check_synthesis ../../hdl/deserializer_stage_energies.vhd
vcom -check_synthesis ../../hdl/deserializer_stage_muons.vhd
vcom -check_synthesis ../../hdl/Sorting/SorterUnit.vhd
vcom -check_synthesis ../../hdl/MatchAndMerge/*
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit.vhd
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
# Insert iso stuff here.
vcom -check_synthesis ../../hdl/ipbus_decode_extrapolation_eta.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_extrapolation_phi.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_extrapolation_regional.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_extrapolation.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_idx_bit_mems_eta.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_idx_bit_mems_phi.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_idx_bits_regional.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_index_bits.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_isolation_mem_absolute.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_isolation_mem_relative.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_isolation_assignment.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_isolation.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_uGMT.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_ugmt_serdes.vhd
vcom -check_synthesis ../../hdl/Isolation/extrapolate_eta.vhd
vcom -check_synthesis ../../hdl/Isolation/extrapolate_phi.vhd
vcom -check_synthesis ../../hdl/Isolation/extrapolation_unit_regional.vhd
vcom -check_synthesis ../../hdl/Isolation/extrapolation_unit.vhd
vcom -check_synthesis ../../hdl/Isolation/compute_complete_sums.vhd
vcom -check_synthesis ../../hdl/Isolation/compute_energy_strip_sums.vhd
vcom -check_synthesis ../../hdl/Isolation/eta_index_bits_mem.vhd
vcom -check_synthesis ../../hdl/Isolation/phi_index_bits_mem.vhd
vcom -check_synthesis ../../hdl/Isolation/eta_index_bits_memories.vhd
vcom -check_synthesis ../../hdl/Isolation/phi_index_bits_memories.vhd
vcom -check_synthesis ../../hdl/Isolation/index_bits_generator.vhd
vcom -check_synthesis ../../hdl/Isolation/generate_index_bits.vhd
vcom -check_synthesis ../../hdl/Isolation/iso_check_abs.vhd
vcom -check_synthesis ../../hdl/Isolation/iso_check_rel.vhd
vcom -check_synthesis ../../hdl/Isolation/iso_check.vhd
vcom -check_synthesis ../../hdl/Isolation/IsoAssignmentUnit.vhd
vcom -check_synthesis ../../hdl/GMT.vhd
vcom -check_synthesis ../../hdl/serializer_stage.vhd
vcom -check_synthesis ../../hdl/ugmt_serdes.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis ugmt_serdes_tb.vhd
ln -s ../../hdl/ipbus_slaves/SortRank.mif .
ln -s ../../hdl/ipbus_slaves/BEtaExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/BPhiExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/OEtaExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/OPhiExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/FEtaExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/FPhiExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/RelIsoCheckMem.mif .
ln -s ../../hdl/ipbus_slaves/AbsIsoCheckMem.mif .
ln -s ../../hdl/ipbus_slaves/IdxSelMemEta.mif .
ln -s ../../hdl/ipbus_slaves/IdxSelMemPhi.mif .
ln -s ../../hdl/ipbus_slaves/BrlSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/OvlPosSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/OvlNegSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FwdPosSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FwdNegSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/BOPosMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/BONegMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FOPosMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/FONegMatchQual.mif .
vmake work > Makefile
bash update_testfiles.sh
echo "WARNING: Using many_events.txt pattern file. Modify $PATTERNFILE link if other pattern file required."
if [ -f $PATTERNFILE ];
then
    rm -f $PATTERNFILE
fi
ln -s integration_many_events.txt $PATTERNFILE
