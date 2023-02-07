################################################################################
# Makefile for vitis embedded sdk project
#
# quick usage:
#   $ make xsct    # get xsct console
#   $ make restore # restore project files accoding to current directory path
#   $ make build   # restore -> full compilation via local installed Xilinx tools
#   $ make program # one-time FPGA configuration from {project_with_elf}.bit
#   $ make run     # load elf via writer cable and connect to virtual JTAG console
#   $ make ide     # open vitis GUI
#   $ make clean   # clean up generated files
################################################################################

.PHONY: default xsct restore build program run ide clean

SCRIPT_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
XSCT_PATH=$(shell readlink -f $(shell which xsct))
XBIN_ROOT=$(shell dirname $(XSCT_PATH))

default: build

# launch xsct
xsct:
	xvfb-run $(XBIN_ROOT)/loader -exec rdi_xsct

# Restore the workspace.
restore: workspace

workspace:
	@if !(type xvfb-run > /dev/null 2>&1); then echo "command 'xvfb-run' not found." ; exit 1 ; fi
	@if !(type xsct > /dev/null 2>&1); then echo "command 'xsct' not found." ; exit 1 ; fi
	sudo chmod go+w /dev/stdout
	xvfb-run $(XBIN_ROOT)/loader -exec rdi_xsct restore.tcl

# build under vitis introduced to PATH
build: workspace
	@if !(type xvfb-run > /dev/null 2>&1); then echo "command 'xvfb-run' not found." ; exit 1 ; fi
	@if !(type xsct > /dev/null 2>&1); then echo "command 'xsct' not found." ; exit 1 ; fi
	sudo chmod go+w /dev/stdout
	xvfb-run $(XBIN_ROOT)/loader -exec rdi_xsct build.tcl

# program FPGA with embedded elf
program: workspace workspace/pl_system_wrapper_with_elf.bit
	@if !(type xvfb-run > /dev/null 2>&1); then echo "command 'xvfb-run' not found." ; exit 1 ; fi
	@if !(type xsct > /dev/null 2>&1); then echo "command 'xsct' not found." ; exit 1 ; fi
	sudo chmod go+w /dev/stdout
	xvfb-run $(XBIN_ROOT)/loader -exec rdi_xsct program.tcl

# reset processor, load elf, connect virtual JTAG terminal and release processor
run: workspace workspace/mb_system/Debug/mb_system.elf
	@if !(type xvfb-run > /dev/null 2>&1); then echo "command 'xvfb-run' not found." ; exit 1 ; fi
	@if !(type xsct > /dev/null 2>&1); then echo "command 'xsct' not found." ; exit 1 ; fi
	sudo chmod go+w /dev/stdout
	xvfb-run $(XBIN_ROOT)/loader -exec rdi_xsct run.tcl

# open Vitis GUI
ide: workspace
	@if !(type vitis > /dev/null 2>&1); then echo "command 'vitis' not found." ; exit 1 ; fi
	vitis --workspace=workspace

# cleanup generated files
clean:
	rm -rf workspace .Xil
	rm -f *.log *.jou *.log *.str
