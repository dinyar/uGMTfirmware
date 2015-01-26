# Serdes area constraints

# Additional resources for quads
create_pblock deser_x0y0
add_cells_to_pblock [get_pblocks deser_x0y0] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[0].deserialize}]]
resize_pblock [get_pblocks deser_x0y0] -add {SLICE_X40Y0:SLICE_X49Y49}
resize_pblock [get_pblocks deser_x0y0] -add {RAMB18_X2Y0:RAMB18_X2Y19}
resize_pblock [get_pblocks deser_x0y0] -add {RAMB36_X2Y0:RAMB36_X2Y9}

create_pblock deser_x0y1
add_cells_to_pblock [get_pblocks deser_x0y1] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[1].deserialize}]]
resize_pblock [get_pblocks deser_x0y1] -add {SLICE_X40Y50:SLICE_X49Y99}
resize_pblock [get_pblocks deser_x0y1] -add {RAMB18_X2Y20:RAMB18_X2Y39}
resize_pblock [get_pblocks deser_x0y1] -add {RAMB36_X2Y10:RAMB36_X2Y19}

create_pblock deser_x0y2
add_cells_to_pblock [get_pblocks deser_x0y2] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[2].deserialize}]]
resize_pblock [get_pblocks deser_x0y2] -add {SLICE_X40Y100:SLICE_X49Y149}
resize_pblock [get_pblocks deser_x0y2] -add {RAMB18_X2Y40:RAMB18_X2Y59}
resize_pblock [get_pblocks deser_x0y2] -add {RAMB36_X2Y20:RAMB36_X2Y29}

create_pblock deser_x0y3
add_cells_to_pblock [get_pblocks deser_x0y3] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[3].deserialize}]]
resize_pblock [get_pblocks deser_x0y3] -add {SLICE_X40Y150:SLICE_X49Y199}
resize_pblock [get_pblocks deser_x0y3] -add {RAMB18_X2Y60:RAMB18_X2Y79}
resize_pblock [get_pblocks deser_x0y3] -add {RAMB36_X2Y30:RAMB36_X2Y39}

create_pblock deser_x0y4
add_cells_to_pblock [get_pblocks deser_x0y4] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[4].deserialize}]]
resize_pblock [get_pblocks deser_x0y4] -add {SLICE_X40Y200:SLICE_X49Y249}
resize_pblock [get_pblocks deser_x0y4] -add {RAMB18_X2Y80:RAMB18_X2Y99}
resize_pblock [get_pblocks deser_x0y4] -add {RAMB36_X2Y40:RAMB36_X2Y49}

create_pblock deser_x0y5
add_cells_to_pblock [get_pblocks deser_x0y5] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[5].deserialize}]]
resize_pblock [get_pblocks deser_x0y5] -add {SLICE_X40Y250:SLICE_X49Y299}
resize_pblock [get_pblocks deser_x0y5] -add {RAMB18_X2Y100:RAMB18_X2Y119}
resize_pblock [get_pblocks deser_x0y5] -add {RAMB36_X2Y50:RAMB36_X2Y59}

create_pblock deser_x0y6
add_cells_to_pblock [get_pblocks deser_x0y6] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[6].deserialize}]]
resize_pblock [get_pblocks deser_x0y6] -add {SLICE_X40Y300:SLICE_X49Y349}
resize_pblock [get_pblocks deser_x0y6] -add {RAMB18_X2Y120:RAMB18_X2Y139}
resize_pblock [get_pblocks deser_x0y6] -add {RAMB36_X2Y60:RAMB36_X2Y69}

create_pblock deser_x0y7
add_cells_to_pblock [get_pblocks deser_x0y7] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[7].deserialize}]]
resize_pblock [get_pblocks deser_x0y7] -add {SLICE_X40Y350:SLICE_X49Y399}
resize_pblock [get_pblocks deser_x0y7] -add {RAMB18_X2Y140:RAMB18_X2Y159}
resize_pblock [get_pblocks deser_x0y7] -add {RAMB36_X2Y70:RAMB36_X2Y79}

create_pblock deser_x0y8
add_cells_to_pblock [get_pblocks deser_x0y8] [get_cells -quiet [list {algo/deserialize_muons/deserialize_loop[8].deserialize}]]
resize_pblock [get_pblocks deser_x0y8] -add {SLICE_X40Y400:SLICE_X49Y449}
resize_pblock [get_pblocks deser_x0y8] -add {RAMB18_X2Y160:RAMB18_X2Y179}
resize_pblock [get_pblocks deser_x0y8] -add {RAMB36_X2Y80:RAMB36_X2Y89}

create_pblock deser_x1y0
add_cells_to_pblock [get_pblocks deser_x1y0] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[0].deserialize}]]
resize_pblock [get_pblocks deser_x1y0] -add {SLICE_X172Y0:SLICE_X179Y49}
create_pblock deser_x1y1
add_cells_to_pblock [get_pblocks deser_x1y1] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[1].deserialize}]]
resize_pblock [get_pblocks deser_x1y1] -add {SLICE_X172Y50:SLICE_X179Y99}
create_pblock deser_x1y2
add_cells_to_pblock [get_pblocks deser_x1y2] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[2].deserialize}]]
resize_pblock [get_pblocks deser_x1y2] -add {SLICE_X172Y100:SLICE_X179Y149}
create_pblock deser_x1y3
add_cells_to_pblock [get_pblocks deser_x1y3] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[3].deserialize}]]
resize_pblock [get_pblocks deser_x1y3] -add {SLICE_X172Y150:SLICE_X179Y199}
create_pblock deser_x1y4
add_cells_to_pblock [get_pblocks deser_x1y4] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[4].deserialize}]]
resize_pblock [get_pblocks deser_x1y4] -add {SLICE_X172Y200:SLICE_X179Y249}
create_pblock deser_x1y5
add_cells_to_pblock [get_pblocks deser_x1y5] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[5].deserialize}]]
resize_pblock [get_pblocks deser_x1y5] -add {SLICE_X172Y250:SLICE_X179Y299}
create_pblock deser_x1y6
add_cells_to_pblock [get_pblocks deser_x1y6] [get_cells -quiet [list {algo/deserialize_energies/deserialize_loop[6].deserialize}]]
resize_pblock [get_pblocks deser_x1y6] -add {SLICE_X172Y300:SLICE_X179Y349}

create_pblock ser_x1y8
add_cells_to_pblock [get_pblocks ser_x1y8] [get_cells -quiet [list algo/serialize]]
resize_pblock [get_pblocks ser_x1y8] -add {SLICE_X172Y50:SLICE_X179Y449}


# Algo area constraints
create_pblock cou_f_plus
add_cells_to_pblock [get_pblocks cou_f_plus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_f_plus]]
resize_pblock [get_pblocks cou_f_plus] -add {SLICE_X50Y400:SLICE_X87Y449}

create_pblock cou_fo_plus
add_cells_to_pblock [get_pblocks cou_fo_plus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_fo_plus]]
resize_pblock [get_pblocks cou_fo_plus] -add {SLICE_X50Y350:SLICE_X87Y399}

create_pblock cou_o_plus
add_cells_to_pblock [get_pblocks cou_o_plus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_o_plus]]
resize_pblock [get_pblocks cou_o_plus] -add {SLICE_X50Y300:SLICE_X87Y349}

create_pblock cou_bo_plus
add_cells_to_pblock [get_pblocks cou_bo_plus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_bo_plus]]
resize_pblock [get_pblocks cou_bo_plus] -add {SLICE_X50Y250:SLICE_X105Y299}

create_pblock cou_b
add_cells_to_pblock [get_pblocks cou_b] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_b]]
resize_pblock [get_pblocks cou_b] -add {SLICE_X50Y200:SLICE_X105Y249}

create_pblock cou_bo_minus
add_cells_to_pblock [get_pblocks cou_bo_minus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_bo_minus]]
resize_pblock [get_pblocks cou_bo_minus] -add {SLICE_X50Y150:SLICE_X105Y199}

create_pblock cou_o_minus
add_cells_to_pblock [get_pblocks cou_o_minus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_o_minus]]
resize_pblock [get_pblocks cou_o_minus] -add {SLICE_X50Y100:SLICE_X87Y149}

create_pblock cou_fo_minus
add_cells_to_pblock [get_pblocks cou_fo_minus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_fo_minus]]
resize_pblock [get_pblocks cou_fo_minus] -add {SLICE_X50Y50:SLICE_X87Y99}

create_pblock cou_f_minus
add_cells_to_pblock [get_pblocks cou_f_minus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/cou_f_minus]]
resize_pblock [get_pblocks cou_f_minus] -add {SLICE_X50Y0:SLICE_X87Y49}

create_pblock sort_f_plus
add_cells_to_pblock [get_pblocks sort_f_plus] [get_cells -quiet [list algo/uGMT/sort_and_cancel/sortF_plus]]
resize_pblock [get_pblocks sort_f_plus] -add {SLICE_X106Y400:SLICE_X159Y449}
