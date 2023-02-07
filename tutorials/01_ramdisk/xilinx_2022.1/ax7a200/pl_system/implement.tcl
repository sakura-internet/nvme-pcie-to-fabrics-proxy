if { [llength $argv] < 3 } {
    error "Usage: vivado -mode batch implement.tcl -tclargs <ProjectName> <TopModuleName> <NumJobsParallel>"
}

set project_name      [lindex $argv 0]
set top_module_name   [lindex $argv 1]
set num_jobs_parallel [lindex $argv 2]

open_project project/${project_name}

update_compile_order -fileset sources_1
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs ${num_jobs_parallel}
wait_on_run impl_1

write_hw_platform -fixed -force  -include_bit -file ./project/${top_module_name}.xsa
