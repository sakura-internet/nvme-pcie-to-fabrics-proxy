set bit_file [lindex $argv 0]
set mcs_file [lindex $argv 1]
write_cfgmem -format mcs -size 1024 -interface SPIx4 \
    -loadbit "up 0x01002000 ${bit_file}" \
    -force -file ${mcs_file}
