################################################################################
# Makefile for vivado Project
#
# quick usage:
#   $ make restore      # restore project from $(SRC_FILE_TCL) and $(BD_TCL)
#   $ make build        # full compilation via local installed Xilinx tools
#   $ make program      # one-time configuration to FPGA CRAM
#   $ make ide          # open vivado GUI with $(PROJ_NAME)
#   $ make export       # regenerate src_file.tcl according to source files in `srcs` directory
#   $ make clean        # export IPs & clean up generated files
################################################################################

.PHONY: default restore build program ide export clean

SCRIPT_DIR         := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJ_NAME          := pl_system
PROJ_PATH          := project/$(PROJ_NAME).xpr
BOARD_REPO_PATH    := $(abspath .)
IP_REPO_PATHS      := $(abspath ../hls_repo)
BOARD_PART_MODE    := true # BoardPart : true, FPGAPart : false
BOARD_OR_FPGA_PART := xilinx.com:au50:part0:1.3
SRC_FILE_TCL       := $(abspath src_file.tcl)
SRC_FILE_PATH      := $(abspath srcs)
TOP_MODULE_NAME    := pl_system_wrapper
BD_TCL             := $(abspath pl_system.tcl)
BD_NAME            := pl_system
NUM_JOBS_PARALLEL  := 4

# default entry
default: build

# restore Vivado project
restore: $(PROJ_PATH)

$(PROJ_PATH):
	@if !(type vivado > /dev/null 2>&1); then echo "command 'vivado' not found." ; exit 1 ; fi
	sed -e 's/{{current_dir}}/$(subst /,\/,$(shell pwd))/g' $(BD_TCL) > $(basename $(BD_TCL))_run.tcl
	vivado -mode batch -source restore.tcl -tclargs $(PROJ_NAME) $(BOARD_REPO_PATH) "$(IP_REPO_PATHS)" $(BOARD_PART_MODE) $(BOARD_OR_FPGA_PART) $(SRC_FILE_TCL) $(SRC_FILE_PATH) $(basename $(BD_TCL))_run.tcl $(BD_NAME)

# build all
build: $(PROJ_PATH)
	@if !(type vivado > /dev/null 2>&1); then echo "command 'vivado' not found." ; exit 1 ; fi
	vivado -mode batch -source implement.tcl -tclargs $(PROJ_NAME) $(TOP_MODULE_NAME) $(NUM_JOBS_PARALLEL)

# write to FPGA CRAM
program:
	@if !(type vivado > /dev/null 2>&1); then echo "command 'vivado' not found." ; exit 1 ; fi
	vivado -mode batch -source program.tcl -tclargs $(PROJ_NAME) $(TOP_MODULE_NAME)

# open vivado GUI
ide: $(PROJ_PATH)
	@if !(type vivado > /dev/null 2>&1); then echo "command 'vivado' not found." ; exit 1 ; fi
	vivado $(PROJ_PATH) &

# record all .v, .sv, xci, .xdc in srcs folder into src_file.tcl
export: $(PROJ_PATH)
	@if [ -f src_file.tcl.bak ]; then echo "backup file 'src_file.tcl.bak' already exists. stopped."; exit 1; fi
	@if [ -f $(BD_TCL).bak ]; then echo "backup file '$(BD_TCL).bak' already exists. stopped."; exit 1; fi
	mv src_file.tcl src_file.tcl.bak
	echo "set src_path [lindex \$${argv} 0]" > src_file.tcl
	find $(SRC_FILE_PATH) -name "*.v" ! -name "*tb.v" -exec bash -c "echo \"add_files {} -fileset [get_filesets sources_1]\" >> src_file.tcl" \;
	find $(SRC_FILE_PATH) -name "*.sv" ! -name "*tb.sv" -exec bash -c "echo \"add_files {} -fileset [get_filesets sources_1]\" >> src_file.tcl" \;
	find $(SRC_FILE_PATH) -name "*.xci" -exec bash -c "echo \"add_files {} -fileset [get_filesets sources_1]\" >> src_file.tcl" \;
	find $(SRC_FILE_PATH) -name "*.xcix" -exec bash -c "echo \"add_files {} -fileset [get_filesets sources_1]\" >> src_file.tcl" \;
	find $(SRC_FILE_PATH) -name "*.xdc" -exec bash -c "echo \"add_files {} -fileset [get_filesets constrs_1]\" >> src_file.tcl" \;
	echo "add_files $${src_path}/../../ext_resource/alveo-u50-xdc.xdc -fileset [get_filesets constrs_1]" >> src_file.tcl
	sed -i -e 's/$(subst /,\/,$(SRC_FILE_PATH))/\$${src_path}/g' src_file.tcl
	cp $(BD_TCL) $(BD_TCL).bak
	sed -i -e 's/$(subst /,\/,$(shell pwd))/{{current_dir}}/g' $(BD_TCL)

# cleanup generated files
clean:
	rm -f $(basename $(BD_TCL))_run.tcl
	rm -f vivado*.log vivado*.jou vivado*.str 
	rm -rf project
	rm -rf .Xil NA
	rm -f *.sysdef *.log
