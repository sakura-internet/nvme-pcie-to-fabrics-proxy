############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
############################################################
open_project blink
set_top blink
add_files src/common.h
add_files src/blink.h
add_files src/blink.cpp
add_files -tb src/blink_tb.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
open_solution "blink" -flow_target vivado
set_part {xc7a200t-fbg484-2}
create_clock -period 5 -name default
config_export -format ip_catalog -rtl verilog -vivado_clock 2
set_clock_uncertainty 0.5
source "./blink/blink/directives.tcl"
csynth_design
export_design -rtl verilog -format ip_catalog
