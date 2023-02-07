setws workspace
platform create -name pl_system_wrapper -hw ../pl_system/project/pl_system_wrapper.xsa -arch {32-bit}
domain create -name {domain_mb} -display-name {domain_mb} -os {standalone} -proc {mb_system_mb} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
app create -name mb_system -platform pl_system_wrapper -domain domain_mb -proc mb_system_mb -template "Empty Application"
# Since importsources with -soft-link option does not work, we have to create a symlink to the src directory manually by invoking ln command.
# original : importsources -name mb_system -path [file normalize src] -soft-link -linker-script
exec rm -r workspace/mb_system/src
exec ln -s [file normalize srcs] [file normalize workspace/mb_system/src]
