# Tcl script generated by PlanAhead

set reloadAllCoreGenRepositories false

set tclUtilsPath "/opt/Xilinx/14.6/ISE_DS/PlanAhead/scripts/pa_cg_utils.tcl"

set repoPaths ""

set cgIndexMapPath "/home/scratch/vhdl/uGMT/dev/ugmt-1_0_4-serdes-algos-complete/mp7_690es/work/PA_ise-import/PA_ise-import.srcs/sources_1/ip/cg_lin_index_map.xml"

set cgProjectPath "/home/scratch/vhdl/uGMT/dev/ugmt-1_0_4-serdes-algos-complete/mp7_690es/cores/coregen.cgc"

set ipFile "/home/scratch/vhdl/uGMT/dev/ugmt-1_0_4-serdes-algos-complete/mp7_690es/cores/phi_extrapolation_mem.xco"

set ipName "phi_extrapolation_mem"

set chains "CUSTOMIZE_CURRENT_CHAIN INSTANTIATION_TEMPLATES_CHAIN"

set bomFilePath "/home/scratch/vhdl/uGMT/dev/ugmt-1_0_4-serdes-algos-complete/mp7_690es/cores/pa_cg_bom.xml"

set cgPartSpec "xc7vx690t-2ffg1927"

set hdlType "VHDL"

# generate the IP
set result [source "/opt/Xilinx/14.6/ISE_DS/PlanAhead/scripts/pa_cg_reconfig_core.tcl"]

exit $result

