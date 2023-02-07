vsim tb
add wave -divider tb
add wave sim:/tb/*
add wave -divider axi_logger_inst
add wave sim:/tb/dut/*
run -all
