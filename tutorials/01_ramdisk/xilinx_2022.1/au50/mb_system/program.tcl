setws workspace
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Xilinx Alveo-DMBv1 FT4232H*" && level==0} -index 0
fpga -file workspace/pl_system_wrapper_with_elf.bit
