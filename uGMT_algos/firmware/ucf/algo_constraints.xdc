# Serdes area constraints

# Additional resources for quads
add_cells_to_pblock [get_pblocks payload_9] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[0].deserialize}]]
add_cells_to_pblock [get_pblocks payload_10] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[1].deserialize}]]
add_cells_to_pblock [get_pblocks payload_11] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[2].deserialize}]]
add_cells_to_pblock [get_pblocks payload_12] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[3].deserialize}]]
add_cells_to_pblock [get_pblocks payload_13] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[4].deserialize}]]
add_cells_to_pblock [get_pblocks payload_14] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[5].deserialize}]]
add_cells_to_pblock [get_pblocks payload_15] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[6].deserialize}]]
add_cells_to_pblock [get_pblocks payload_16] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[7].deserialize}]]
add_cells_to_pblock [get_pblocks payload_17] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[8].deserialize}]]

create_pblock deser_x1y0
add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[6].deserialize}]]
resize_pblock [get_pblocks deser_x1y0] -add {SLICE_X162Y0:SLICE_X179Y49}
create_pblock deser_x1y1
add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[5].deserialize}]]
resize_pblock [get_pblocks deser_x1y1] -add {SLICE_X162Y50:SLICE_X179Y99}
create_pblock deser_x1y2
add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[4].deserialize}]]
resize_pblock [get_pblocks deser_x1y2] -add {SLICE_X162Y100:SLICE_X179Y149}
create_pblock deser_x1y3
add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[3].deserialize}]]
resize_pblock [get_pblocks deser_x1y3] -add {SLICE_X162Y150:SLICE_X179Y199}
create_pblock deser_x1y4
add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[2].deserialize}]]
resize_pblock [get_pblocks deser_x1y4] -add {SLICE_X162Y200:SLICE_X179Y249}
create_pblock deser_x1y5
add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[1].deserialize}]]
resize_pblock [get_pblocks deser_x1y5] -add {SLICE_X162Y250:SLICE_X179Y299}
create_pblock deser_x1y6
add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[0].deserialize}]]
resize_pblock [get_pblocks deser_x1y6] -add {SLICE_X162Y300:SLICE_X179Y349}

create_pblock ser_x1y8
add_cells_to_pblock [get_pblocks ser_x1y8] [get_cells -quiet [list algo/serialize]]
resize_pblock [get_pblocks ser_x1y8] -add {SLICE_X152Y300:SLICE_X179Y449}

# Algo area constraints
add_cells_to_pblock [get_pblocks payload_8] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_f_plus]]
add_cells_to_pblock [get_pblocks payload_7] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_fo_plus]]
add_cells_to_pblock [get_pblocks payload_6] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_o_plus]]
add_cells_to_pblock [get_pblocks payload_5] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_bo_plus]]
add_cells_to_pblock [get_pblocks payload_4] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_b]]
add_cells_to_pblock [get_pblocks payload_3] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_bo_minus]]
add_cells_to_pblock [get_pblocks payload_2] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_o_minus]]
add_cells_to_pblock [get_pblocks payload_1] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_fo_minus]]
add_cells_to_pblock [get_pblocks payload_0] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_f_minus]]
