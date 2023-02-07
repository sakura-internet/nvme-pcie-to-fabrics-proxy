if { [llength $argv] < 2 } {
    error "Usage: vivado -mode batch flash.tcl -tclargs <ProjectName> <TopModuleName>"
}

set project_name     [lindex $argv 0]
set top_module_name  [lindex $argv 1]

open_project pl_system/project/${project_name}.xpr
update_compile_order -fileset sources_1

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

current_hw_device [get_hw_devices xcu50_u55n_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcu50_u55n_0] 0]
create_hw_cfgmem -hw_device [get_hw_devices xcu50_u55n_0] -mem_dev [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4}] 0]

set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.FILES [list "output/${top_module_name}_with_elf.mcs" ] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.PRM_FILE "output/${top_module_name}_with_elf.prm" [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
startgroup 
create_hw_bitstream -hw_device [lindex [get_hw_devices xcu50_u55n_0] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices xcu50_u55n_0] 0]]; program_hw_devices [lindex [get_hw_devices xcu50_u55n_0] 0]; refresh_hw_device [lindex [get_hw_devices xcu50_u55n_0] 0];
program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcu50_u55n_0] 0]]
endgroup
