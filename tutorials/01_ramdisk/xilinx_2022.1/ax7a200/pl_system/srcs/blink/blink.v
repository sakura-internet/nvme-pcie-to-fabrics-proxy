`timescale 1 ns / 100 ps
module blink(
	input clk,
	input arst_n,
	output gpio_out
);
	// (* mark_debug = "true" *)
	reg [26:0] cnt_r;
	assign gpio_out = cnt_r[26];
	always @ (posedge clk or negedge arst_n) begin
		if (! arst_n) begin
			cnt_r <= 27'd0;
		end else begin
			cnt_r <= cnt_r + 27'd1;
		end
	end
endmodule
