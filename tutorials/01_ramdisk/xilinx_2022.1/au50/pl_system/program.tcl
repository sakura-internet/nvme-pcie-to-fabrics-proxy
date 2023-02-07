if { [llength $argv] < 2 } {
    error "Usage: vivado -mode batch program.tcl -tclargs <ProjectName> <TopModuleName>"
}

set project_name    [lindex $argv 0]
set top_module_name [lindex $argv 1]

open_project project/${project_name}.xpr
update_compile_order -fileset sources_1

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

current_hw_device [get_hw_devices xcu50_u55n_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcu50_u55n_0] 0]

set_property PROBES.FILE {} [get_hw_devices xcu50_u55n_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xcu50_u55n_0]
set_property PROGRAM.FILE "project/${project_name}.runs/impl_1/${top_module_name}.bit" [get_hw_devices xcu50_u55n_0]
program_hw_devices [get_hw_devices xcu50_u55n_0]
