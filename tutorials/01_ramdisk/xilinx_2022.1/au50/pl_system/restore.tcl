if { [llength $argv] < 9 } {
    error "Usage: vivado -mode tcl restore_project.tcl --tclargs <ProjectName> <BoardRepoPath> \"<IPRepoPaths>\" <BoardPartMode:true, FPGAPartMode:false> <BoardPart or FPGAPart> <SrcFileTcl> <SrcFilePath> <BDTcl> <BDName>"
}

set project_name       [lindex $argv 0]
set board_repo_path    [lindex $argv 1]
set ip_repo_paths      [lindex $argv 2]
set board_part_mode    [lindex $argv 3]
set board_or_fpga_part [lindex $argv 4]
set src_file_tcl       [lindex $argv 5]
set src_file_path      [lindex $argv 6]
set bd_tcl             [lindex $argv 7]
set bd_name            [lindex $argv 8]

create_project project/${project_name} .

# add board_files repositories and specify board_part
set_param board.repoPaths [concat [file normalize ${board_repo_path}] [get_param board.repoPaths]]
set_property BOARD_PART_REPO_PATHS [get_param board.repoPaths] [current_project]

# add ip and hls repositories
set ip_repo_path_list [split ${ip_repo_paths} " "]
set_property IP_REPO_PATHS [file normalize ${ip_repo_path_list}] [get_filesets sources_1]
update_ip_catalog

# specify board part or FPGA part according to ${board_part_mode}
if { ${board_part_mode} } {
    set_property board_part ${board_or_fpga_part} [current_project]
} else {
    set_property part ${board_or_fpga_part} [current_project]
}

# add source files
set argv [list ${src_file_path}]
set argc 2
source ${src_file_tcl}

# restore board design
set argv ""
set argc 0
source ${bd_tcl}

# uncomment below to enable auto-generated bd wrapper
#make_wrapper -top -fileset sources_1 -import [get_files project/$project_name.srcs/sources_1/bd/${bd_name}/${bd_name}.bd]
