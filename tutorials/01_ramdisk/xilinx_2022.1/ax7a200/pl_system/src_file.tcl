set src_path [lindex ${argv} 0]
#add_files ${src_path}/msi_intc/tb.v -fileset [get_filesets sources_1]
add_files ${src_path}/msi_intc/msi_intc.v -fileset [get_filesets sources_1]
add_files ${src_path}/top/pl_system_wrapper.v -fileset [get_filesets sources_1]
#add_files ${src_path}/blink/tb.v -fileset [get_filesets sources_1]
add_files ${src_path}/blink/blink.v -fileset [get_filesets sources_1]
add_files ${src_path}/xdma_irqreg_remapper/xdma_irqreg_remapper.v -fileset [get_filesets sources_1]
add_files ${src_path}/sys_pll.xcix -fileset [get_filesets sources_1]
add_files ${src_path}/ax7a200.xdc -fileset [get_filesets constrs_1]