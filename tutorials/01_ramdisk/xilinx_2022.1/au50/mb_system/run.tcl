setws workspace
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw workspace/pl_system_wrapper/export/pl_system_wrapper/hw/pl_system_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
rst -processor
dow workspace/mb_system/Debug/mb_system.elf
con
set port [ jtagterminal -start -socket ]
exec telnet 127.0.0.1 $port > /dev/stdout
