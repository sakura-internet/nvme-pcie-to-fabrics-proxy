# hls\_system vitis\_hls project

## files

- README.md : this file
- Makefile : build helper calls {module\_name}/Makefile recursively
  + {module\_name}/Makefile : run "HDL synthesis -> Export IP" flow

## how to add new vitis\_hls IP

- mkdir "new\_ip" directory and copy Makefile and src directory into it
- cd "new\_ip" directory and type `$ vitis_hls`
- select "new project" menu and specify new project name
- add files in src dir except \*\_tb.cpp on "add design files" tab
- add \*\_tb.cpp -named files in src dir on "add testbench files" tab
- specify solution name, set period, uncertainty, part select on settings tab
- modify "new\_ip/Makefile" according to your settings
- add "new\_ip" entry to SUBDIRS variable on Makefile this directory
