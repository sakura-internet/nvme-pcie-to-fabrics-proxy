#-------------------------------------------------------------------------------
# Makefile for xsim
#
# usage :
#   make build => compile
#   make sim   => simulation with CUI
#   make simx  => simulation with GUI
#   make clean => cleanup
#-------------------------------------------------------------------------------
.PHONY : all vlog premake clean

SRCS = *.v
TOP_MODULE = tb

default : build

build :
	xvlog $(SRCS)
	xelab -debug typical $(TOP_MODULE) -s $(TOP_MODULE).sim

sim : build
	xsim --runall $(TOP_MODULE).sim

simx : build
	xsim tb.sim -gui

clean :
	@rm -rf *.log *.jou *.pb tb.sim.wdb dump.vcd xsim.dir
