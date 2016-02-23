# Serdes area constraints

# Additional resources for quads
add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[0].deserialize}]]
add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[0].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[1].deserialize}]]
add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[1].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[2].deserialize}]]
add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[2].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[3].deserialize}]]
add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[3].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[4].deserialize}]]
add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[4].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[5].deserialize}]]
add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[5].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[6].deserialize}]]
add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[6].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[7].deserialize}]]
add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[7].extrapolate}]]
add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[8].deserialize}]]
add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet [list {payload/muon_input_stage/deserialize_loop[8].extrapolate}]]

add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[6].deserialize}]]
add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[5].deserialize}]]
add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[4].deserialize}]]
add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[3].deserialize}]]
add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[2].deserialize}]]
add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[1].deserialize}]]
add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet [list {payload/energy_input_stage/deserialize_loop[0].deserialize}]]

create_pblock ser_x1y8
resize_pblock [get_pblocks ser_x1y8] -add {SLICE_X152Y50:SLICE_X179Y449}
add_cells_to_pblock [get_pblocks ser_x1y8] [get_cells -quiet [list payload/serialize]]

# Algo area constraints
add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_e_plus]]
add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_eo_plus]]
add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_o_plus]]
add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_bo_plus]]
add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_b]]
add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_bo_minus]]
add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_o_minus]]
add_cells_to_pblock [get_pblocks payload_1] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_eo_minus]]
add_cells_to_pblock [get_pblocks payload_0] [get_cells -quiet [list payload/uGMT/sort_and_cancel/cou_e_minus]]
