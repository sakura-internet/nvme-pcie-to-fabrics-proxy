setws workspace
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS1*" && level==0}
fpga -file workspace/pl_system_wrapper_with_elf.bit
