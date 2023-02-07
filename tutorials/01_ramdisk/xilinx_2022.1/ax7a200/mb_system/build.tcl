setws workspace
platform read workspace/pl_system_wrapper/platform.spr
platform config -updatehw ../pl_system/project/pl_system_wrapper.xsa

puts "building app ..."
app build -name mb_system

puts "embedding elf ..."
exec updatemem -force \
    -meminfo ../pl_system/project/pl_system.runs/impl_1/pl_system_wrapper.mmi \
    -bit ../pl_system/project/pl_system.runs/impl_1/pl_system_wrapper.bit \
    -data workspace/mb_system/Debug/mb_system.elf \
    -proc pl_system_inst/mb_system/mb \
    -out workspace/pl_system_wrapper_with_elf.bit > /dev/stdout

puts "converting to mcs ..."
exec vivado -mode batch -source generate_mcs.tcl -tclargs workspace/pl_system_wrapper_with_elf.bit workspace/pl_system_wrapper_with_elf.mcs > /dev/stdout
