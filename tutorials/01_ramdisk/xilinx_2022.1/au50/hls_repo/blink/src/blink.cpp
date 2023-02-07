#include "common.h"
#include "blink.h"

void blink(volatile UINT32* gpio_out) {
	//#pragma HLS DATAFLOW
	//#pragma HLS INTERFACE m_axi port=gpio_out offset=direct
	#pragma HLS INTERFACE ap_none port=gpio_out
	#pragma HLS INTERFACE ap_ctrl_none port=return

	static UINT32 count = 0x00000000;
	static UINT32 gpio = 0x00000000;

	if (count == 50000000) {
		count = 0;
		gpio = ~gpio;
		*gpio_out = gpio;
	} else {
		count = count + 1;
	}
}
