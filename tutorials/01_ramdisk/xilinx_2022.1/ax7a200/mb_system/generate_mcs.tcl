set bit_file [lindex $argv 0]
set mcs_file [lindex $argv 1]
write_cfgmem -format mcs -size 128 -interface SPIx4 \
    -loadbit "up 0x0 ${bit_file}" \
    -force -file ${mcs_file}
