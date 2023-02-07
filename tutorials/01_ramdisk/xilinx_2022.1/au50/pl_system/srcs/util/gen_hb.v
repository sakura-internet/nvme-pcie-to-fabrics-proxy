module gen_hb
#(parameter FLIP_COUNT = 50000000)
(
	input clk,
	output hb
);
	reg [31:0] cnt_r;
	reg        hb_r;
	always @ (posedge clk) begin
		if (cnt_r < FLIP_COUNT) begin
			cnt_r <= cnt_r + 32'd1;
			hb_r  <= hb_r;
		end else begin
			cnt_r <= 32'd0;
			hb_r  <= ~hb_r;
		end
	end
	assign hb = hb_r;
endmodule
