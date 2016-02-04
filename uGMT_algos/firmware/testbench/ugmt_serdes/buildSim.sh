#!/bin/bash

# TODO: Add warning to modify path to CACTUSREPO here!

################## MODIFY HERE ##################
CACTUSREPOPATH=/home/scratch/ugmt_firmware/mp7fw_current
#################################################

rm -rf ugmt_serdes

vlib ugmt_serdes
vmap work ugmt_serdes
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
vcom -check_synthesis ../../hdl/common/ugmt_constants.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_datapath/firmware/hdl/mp7_data_types.vhd
vcom -check_synthesis ../../hdl/common/GMTTypes_pkg.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_package.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_sorting.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_sort_rank_mems.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_deserialization.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_reg_v.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7_brd_decl.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/boards/mp7/base_fw/common/firmware/hdl/mp7_top_decl.vhd
vcom -check_synthesis ../../hdl/top_decl.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/mp7_ttc/firmware/hdl/mp7_ttc_decl.vhd
vcom -check_synthesis $CACTUSREPOPATH/cactusupgrades/components/ipbus_slaves/firmware/hdl/ipbus_dpram.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_reg_setable.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_reg_status.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_counter.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_permanent_counter.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_dpram_dist.vhd
vcom -check_synthesis ../../hdl/ipbus_slaves/ipbus_initialized_dpram.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_gen_calo_idx_bits.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_cancel_out_*.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_*_input.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_*_deserialization.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_isolation*.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_uGMT.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_muon_counter_reset.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_generate_lemo_signals.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_spy_buffer_control.vhd
vcom -check_synthesis ../../hdl/ipbus_decode_mp7_payload.vhd
vcom -check_synthesis ../../hdl/input_stages/deserialize_energy_quad.vhd
vcom -check_synthesis ../../hdl/input_stages/deserialize_mu_quad.vhd
vcom -check_synthesis ../../hdl/input_stages/gen_idx_bits.vhd
vcom -check_synthesis ../../hdl/input_stages/energy_input.vhd
vcom -check_synthesis ../../hdl/input_stages/muon_input.vhd
vcom -check_synthesis ../../hdl/Sorting/SorterUnit.vhd
vcom -check_synthesis ../../hdl/MatchAndMerge/*
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit_BMTF.vhd
vcom -check_synthesis ../../hdl/GhostBusting/GhostCheckerUnit_spatialCoords.vhd
vcom -check_synthesis ../../hdl/GhostBusting/WedgeCheckerUnit.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_BO_WedgeComp.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_BO.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_EO_WedgeComp.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_EO.vhd
vcom -check_synthesis ../../hdl/GhostBusting/CancelOutUnit_*
vcom -check_synthesis ../../hdl/common/comp10_ge_behavioral.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_countWins.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_Mux.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/SortStage0_behavioral.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage0/HalfSortStage0.vhd
vcom -check_synthesis ../../hdl/Sorting/Stage1/SortStage1_behavioral.vhd
vcom -check_synthesis ../../hdl/Sorting/SortAndCancelUnit.vhd
vcom -check_synthesis ../../hdl/Isolation/compute_complete_sums.vhd
vcom -check_synthesis ../../hdl/Isolation/compute_energy_strip_sums.vhd
vcom -check_synthesis ../../hdl/Isolation/iso_check_abs.vhd
vcom -check_synthesis ../../hdl/Isolation/iso_check_rel.vhd
vcom -check_synthesis ../../hdl/Isolation/iso_check.vhd
vcom -check_synthesis ../../hdl/Isolation/IsoAssignmentUnit.vhd
vcom -check_synthesis ../../hdl/GMT.vhd
vcom -check_synthesis ../../hdl/serializer_stage.vhd
vcom -check_synthesis ../../hdl/muon_counter_reset.vhd
vcom -check_synthesis ../../hdl/generate_lemo_signals.vhd
vcom -check_synthesis ../../hdl/spy_buffer_control.vhd
vcom -check_synthesis ../../hdl/mp7_payload.vhd
vcom -check_synthesis ../tb_helpers.vhd
vcom -check_synthesis ugmt_serdes_tb.vhd

ln -s ../../hdl/ipbus_slaves/SortRank.mif .
ln -s ../../hdl/ipbus_slaves/BEtaExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/BPhiExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/OEtaExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/OPhiExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/EEtaExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/EPhiExtrapolation.mif .
ln -s ../../hdl/ipbus_slaves/RelIsoCheckMem.mif .
ln -s ../../hdl/ipbus_slaves/AbsIsoCheckMem.mif .
ln -s ../../hdl/ipbus_slaves/IdxSelMemEta.mif .
ln -s ../../hdl/ipbus_slaves/IdxSelMemPhi.mif .
ln -s ../../hdl/ipbus_slaves/BmtfSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/OmtfPosSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/OmtfNegSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/EmtfPosSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/EmtfNegSingleMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/BOPosMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/BONegMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/EOPosMatchQual.mif .
ln -s ../../hdl/ipbus_slaves/EONegMatchQual.mif .
vmake work > Makefile
