# software-based NVMe ramdisk tutorial project for ax7a200

## directory & files instruction

- hls\_repo : stores high-level synthesis ip submodule project
  + `$ make` here to compile and package ip via vitis\_hls
  + note : currently there is only "blink" skeleton project it is not used in pl\_system, preventing pl\_system restoration script from failing to set IP\_REPO\_PATHS

- pl\_system : Artix-7 FPGA design includes PCIe Endpoint, DDR3 SDRAM MIG, and MicroBlaze instantiations
  + requires hls\_repo and other directories contains valid ip packages
  + `$ make` here to run vivado "restore project -> synthesis -> implementation -> generate bitstream -> export hardware" flow
  + once completed, you will get `pl_system/project/pl_system_wrapper.xsa` hw handoff module

- mb\_system : software-based NVMe controller design 
  + requires vivado hw handoff file `pl_system/project/pl_system_wrapper.xsa`
  + `$ make` here to restore and build project via vitis, then you will get `mb_system/ctrl/pl_system_wrapper_with_elf.mcs` EEPROM configuration file

- Makefile : store useful make targets
  + `$ make` : `$ make build` -> `$ make output` run
    * `$ make build` : runs build flow on hls\_repo, pl\_system, and mb\_system directories respectively.
    * `$ make output` : collect output files on pl\_system and mb\_system
  + `$ make program` : one-time FPGA configuration via programming cable
  + `$ make flash` : write config into EEPROM on ax7a200 board

## addr map

- Microblaze (/ctrl/mb/Data) 36bits M-AXI
  + `0x0_0000_0000` (128k) : microblaze data memory
  + `0x0_4120_0000` (  4k) : microblaze interrupt controller
  + `0x0_4140_0000` (  4k) : microblaze debug module
  + `0x0_4160_0000` (  4k) : external timer module
  + `0x0_A000_0000` (  4k) : GPIO controller
  + `0x0_A004_0000` (  4k) : PCIe interrupt controller
  + `0x0_A005_0000` (  4k) : control port for AXI firewall prevents MB M-AXI from hang 
  + `0x0_A006_0000` (  4k) : control port for AXI firewall prevents PCIe xdma M-AXI from hang
  + `0x0_A008_0000` (  4k) : PCIe BAR0 SRAM block memory shared with PCIe
  + `0x0_A400_0000` (  4k) : PCIe control port
  + `0x4_0000_0000` (  4G) : PCIe busmaster access for host main memory (lower 32bit)
  + `0x8_0000_0000` (  1G) : DDR3 SDRAM NVMe/PCIe RAMDISK backing store

- Microblaze (/ctrl/mb/Instruction) 32bits M-AXI
  + `0x0000_0000` (128k) : microblaze instruction memory

- PCIe AXI bridge (/pcie\_system/pcie/M\_AXI) 32bits M-AXI
  + `0xA008_0000` (128k) : PCIe BAR0 SRAM block memory shared with microblaze
