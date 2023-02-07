# mb\_system vitis project

## files

- README.md : this file
- Makefile : stores useful shortcut commands
- restore.tcl : script for restoring vitis project
- build.tcl : "build -> embed elf into bitstream" automation script
  + generate\_mcs.tcl : elf embedded image generator for SPI flash ROM
- srcs : stores microblaze source files

## build dependency

- `../pl_system/project/impl_1/pl_system_wrapper.bit`
- `../pl_system/project/impl_1/pl_system_wrapper.mmi`
- `../pl_system/project/pl_system_wrapper.xsa`

## typical development workflow

- clone fresh project
- prepare build dependency
- `make restore` to restore vitis project on `workspace` directory
  + `workspace/mb_system/src` directory will be set up as symlink of `srcs` to make source files persistent
- `make ide` to open vitis project for edit
- `make build` to execute automated "build -> embed elf into bitstream" procedure
  + embed bitstream will be stored on `work/pl_system_wrapper_with_elf.bit`
- `make clean` to remove generated project (make sure all your modification made persistent before clean up)
- `git add' & 'git commit` to submit changes

## open debug terminal on console

- clone fresh project
- prepare build dependency
- `make restore` and `make build` to get workspace/mb\_system/Debug/mb\_system.elf
- `make program` to configure FPGA and its PCIe hard IP
- reboot host where PCIe hard IP connected to
- `make run` to download ctrl.elf and open JTAG virtual console via telnet (currently log stdout only)
- `Ctrl + "]"` -> `quit` to exit telnet terminal
