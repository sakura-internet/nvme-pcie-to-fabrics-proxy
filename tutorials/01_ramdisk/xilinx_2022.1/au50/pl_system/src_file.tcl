set src_path [lindex ${argv} 0]
add_files ${src_path}/msix_intc/msix_intc.v -fileset [get_filesets sources_1]
add_files ${src_path}/top/pl_system_wrapper.v -fileset [get_filesets sources_1]
add_files ${src_path}/xdma_irqreg_remapper/xdma_irqreg_remapper.v -fileset [get_filesets sources_1]
add_files ${src_path}/util/gen_hb.v -fileset [get_filesets sources_1]
add_files ${src_path}/project.xdc -fileset [get_filesets constrs_1]
add_files ../ext_resource/alveo-u50-xdc.xdc -fileset [get_filesets constrs_1]
