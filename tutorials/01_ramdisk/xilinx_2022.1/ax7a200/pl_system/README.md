# pl\_system vivado project

## files

- README.md : this file
- Makefile : stores useful shortcut commands
- restore.tcl : script for restoring vivado project
  + src\_file.tcl : (generated via `make export`) script for adding source files into project
  + pl\_system.tcl : (vivado generated) script for reconstructing pl\_system board design called by restore.tcl
- implement.tcl : "generate bd -> synthesis -> implement -> export xsa" automation script
- srcs : stores RTL modules (.v, .sv), generated IP core definitions (.xci),  and constraints (.xdc)

## build dependency

- `../hls_repo`
  + vivado assumes `vitis_hls` generated IP cores are stored on the directory
  + if you do not need `hls_repo` at all, you can disable this by comment out `IP_REPO_PATH` settings on restore.tcl

## typical development workflow

- clone fresh project
- prepare build dependency
- `make restore` to restore vivado project on `project` directory
- `make ide` to open vivado project for edit
  + any RTL modules and constraints (xdcs) should be stored in srcs directory since `project` directory will be cleared on `make clean`
  + if you added any source / constraints file to srcs directory, `make export` to regenerate src\_file.tcl
  + board design modification can be exported by typing `write_bd_tcl pl_system.tcl -force` on tcl command line
- `make build` to execute automated "generate bd -> synthesis -> implement -> export xsa" procedure (you can also execute them step-by-step on GUI and tcl console)
  + bitstream will be stored on `project/pl_system.runs/impl_1/pl_system_wrapper.bit`
  + xsa file (include bitstream) will be stored in `project/pl_system_wrapper.xsa`
- `make clean` to remove generated project (make sure all your modification made persistent before clean up)
- `git add` & `git commit` to submit changes

