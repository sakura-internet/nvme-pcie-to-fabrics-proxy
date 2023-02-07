`timescale 1 ps / 1 ps
module msix_intc(
	input aclk,
	input aresetn,

	// xdma irq interface
	output [8:0]  usr_irq_req,
	input  [8:0]  usr_irq_ack,

	// s_axi
	input  [7:0]  s_axi_araddr,
	input  [2:0]  s_axi_arprot,
	output        s_axi_arready,
	input         s_axi_arvalid,

	input  [7:0]  s_axi_awaddr,
	input  [2:0]  s_axi_awprot,
	output        s_axi_awready,
	input         s_axi_awvalid,

	input         s_axi_bready,
	output [1:0]  s_axi_bresp,
	output        s_axi_bvalid,

	output [31:0] s_axi_rdata,
	input         s_axi_rready,
	output [1:0]  s_axi_rresp,
	output        s_axi_rvalid,

	input  [31:0] s_axi_wdata,
	output        s_axi_wready,
	input  [3:0]  s_axi_wstrb,
	input         s_axi_wvalid
);

	reg    [8:0]  usr_irq_req_r;
	reg    [3:0]  usr_irq_req_00_cool_r;
	reg    [3:0]  usr_irq_req_01_cool_r;
	reg    [3:0]  usr_irq_req_02_cool_r;
	reg    [3:0]  usr_irq_req_03_cool_r;
	reg    [3:0]  usr_irq_req_04_cool_r;
	reg    [3:0]  usr_irq_req_05_cool_r;
	reg    [3:0]  usr_irq_req_06_cool_r;
	reg    [3:0]  usr_irq_req_07_cool_r;
	reg    [3:0]  usr_irq_req_08_cool_r;

	reg           s_axi_arready_r;
	reg           s_axi_awready_r;
	reg    [1:0]  s_axi_bresp_r;
	reg           s_axi_bvalid_r;
	reg    [8:0]  s_axi_rdata_r;
	reg    [1:0]  s_axi_rresp_r;
	reg           s_axi_rvalid_r;
	reg           s_axi_wready_r;

	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[0] <= 1'b0;
		end else if (usr_irq_ack[0]) begin
			usr_irq_req_r[0] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[0] <= s_axi_wdata[0] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[0] <= usr_irq_req_r[0];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_00_cool_r <= 4'd0;
		end else if (usr_irq_req_r[0] & usr_irq_ack[0]) begin
			usr_irq_req_00_cool_r <= 4'd15;
		end else if (usr_irq_req_00_cool_r != 4'd0) begin
			usr_irq_req_00_cool_r <= usr_irq_req_00_cool_r - 4'd1;
		end else begin
			usr_irq_req_00_cool_r <= usr_irq_req_00_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[0] <= 1'b0;
		end else if (usr_irq_req_r[0] || usr_irq_req_00_cool_r != 4'd0) begin
			s_axi_rdata_r[0] <= 1'b1;
		end else begin
			s_axi_rdata_r[0] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[1] <= 1'b0;
		end else if (usr_irq_ack[1]) begin
			usr_irq_req_r[1] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[1] <= s_axi_wdata[1] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[1] <= usr_irq_req_r[1];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_01_cool_r <= 4'd0;
		end else if (usr_irq_req_r[1] & usr_irq_ack[1]) begin
			usr_irq_req_01_cool_r <= 4'd15;
		end else if (usr_irq_req_01_cool_r != 4'd0) begin
			usr_irq_req_01_cool_r <= usr_irq_req_01_cool_r - 4'd1;
		end else begin
			usr_irq_req_01_cool_r <= usr_irq_req_01_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[1] <= 1'b0;
		end else if (usr_irq_req_r[1] || usr_irq_req_01_cool_r != 4'd0) begin
			s_axi_rdata_r[1] <= 1'b1;
		end else begin
			s_axi_rdata_r[1] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[2] <= 1'b0;
		end else if (usr_irq_ack[2]) begin
			usr_irq_req_r[2] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[2] <= s_axi_wdata[2] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[2] <= usr_irq_req_r[2];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_02_cool_r <= 4'd0;
		end else if (usr_irq_req_r[2] & usr_irq_ack[2]) begin
			usr_irq_req_02_cool_r <= 4'd15;
		end else if (usr_irq_req_02_cool_r != 4'd0) begin
			usr_irq_req_02_cool_r <= usr_irq_req_02_cool_r - 4'd1;
		end else begin
			usr_irq_req_02_cool_r <= usr_irq_req_02_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[2] <= 1'b0;
		end else if (usr_irq_req_r[2] || usr_irq_req_02_cool_r != 4'd0) begin
			s_axi_rdata_r[2] <= 1'b1;
		end else begin
			s_axi_rdata_r[2] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[3] <= 1'b0;
		end else if (usr_irq_ack[3]) begin
			usr_irq_req_r[3] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[3] <= s_axi_wdata[3] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[3] <= usr_irq_req_r[3];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_03_cool_r <= 4'd0;
		end else if (usr_irq_req_r[3] & usr_irq_ack[3]) begin
			usr_irq_req_03_cool_r <= 4'd15;
		end else if (usr_irq_req_03_cool_r != 4'd0) begin
			usr_irq_req_03_cool_r <= usr_irq_req_03_cool_r - 4'd1;
		end else begin
			usr_irq_req_03_cool_r <= usr_irq_req_03_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[3] <= 1'b0;
		end else if (usr_irq_req_r[3] || usr_irq_req_03_cool_r != 4'd0) begin
			s_axi_rdata_r[3] <= 1'b1;
		end else begin
			s_axi_rdata_r[3] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[4] <= 1'b0;
		end else if (usr_irq_ack[4]) begin
			usr_irq_req_r[4] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[4] <= s_axi_wdata[4] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[4] <= usr_irq_req_r[4];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_04_cool_r <= 4'd0;
		end else if (usr_irq_req_r[4] & usr_irq_ack[4]) begin
			usr_irq_req_04_cool_r <= 4'd15;
		end else if (usr_irq_req_04_cool_r != 4'd0) begin
			usr_irq_req_04_cool_r <= usr_irq_req_04_cool_r - 4'd1;
		end else begin
			usr_irq_req_04_cool_r <= usr_irq_req_04_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[4] <= 1'b0;
		end else if (usr_irq_req_r[4] || usr_irq_req_04_cool_r != 4'd0) begin
			s_axi_rdata_r[4] <= 1'b1;
		end else begin
			s_axi_rdata_r[4] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[5] <= 1'b0;
		end else if (usr_irq_ack[5]) begin
			usr_irq_req_r[5] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[5] <= s_axi_wdata[5] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[5] <= usr_irq_req_r[5];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_05_cool_r <= 4'd0;
		end else if (usr_irq_req_r[5] & usr_irq_ack[5]) begin
			usr_irq_req_05_cool_r <= 4'd15;
		end else if (usr_irq_req_05_cool_r != 4'd0) begin
			usr_irq_req_05_cool_r <= usr_irq_req_05_cool_r - 4'd1;
		end else begin
			usr_irq_req_05_cool_r <= usr_irq_req_05_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[5] <= 1'b0;
		end else if (usr_irq_req_r[5] || usr_irq_req_05_cool_r != 4'd0) begin
			s_axi_rdata_r[5] <= 1'b1;
		end else begin
			s_axi_rdata_r[5] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[6] <= 1'b0;
		end else if (usr_irq_ack[6]) begin
			usr_irq_req_r[6] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[6] <= s_axi_wdata[6] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[6] <= usr_irq_req_r[6];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_06_cool_r <= 4'd0;
		end else if (usr_irq_req_r[6] & usr_irq_ack[6]) begin
			usr_irq_req_06_cool_r <= 4'd15;
		end else if (usr_irq_req_06_cool_r != 4'd0) begin
			usr_irq_req_06_cool_r <= usr_irq_req_06_cool_r - 4'd1;
		end else begin
			usr_irq_req_06_cool_r <= usr_irq_req_06_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[6] <= 1'b0;
		end else if (usr_irq_req_r[6] || usr_irq_req_06_cool_r != 4'd0) begin
			s_axi_rdata_r[6] <= 1'b1;
		end else begin
			s_axi_rdata_r[6] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[7] <= 1'b0;
		end else if (usr_irq_ack[7]) begin
			usr_irq_req_r[7] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[7] <= s_axi_wdata[7] & s_axi_wstrb[0];
		end else begin
			usr_irq_req_r[7] <= usr_irq_req_r[7];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_07_cool_r <= 4'd0;
		end else if (usr_irq_req_r[7] & usr_irq_ack[7]) begin
			usr_irq_req_07_cool_r <= 4'd15;
		end else if (usr_irq_req_07_cool_r != 4'd0) begin
			usr_irq_req_07_cool_r <= usr_irq_req_07_cool_r - 4'd1;
		end else begin
			usr_irq_req_07_cool_r <= usr_irq_req_07_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[7] <= 1'b0;
		end else if (usr_irq_req_r[7] || usr_irq_req_07_cool_r != 4'd0) begin
			s_axi_rdata_r[7] <= 1'b1;
		end else begin
			s_axi_rdata_r[7] <= 1'b0;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_r[8] <= 1'b0;
		end else if (usr_irq_ack[8]) begin
			usr_irq_req_r[8] <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			usr_irq_req_r[8] <= s_axi_wdata[8] & s_axi_wstrb[1];
		end else begin
			usr_irq_req_r[8] <= usr_irq_req_r[8];
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			usr_irq_req_08_cool_r <= 4'd0;
		end else if (usr_irq_req_r[8] & usr_irq_ack[8]) begin
			usr_irq_req_08_cool_r <= 4'd15;
		end else if (usr_irq_req_08_cool_r != 4'd0) begin
			usr_irq_req_08_cool_r <= usr_irq_req_08_cool_r - 4'd1;
		end else begin
			usr_irq_req_08_cool_r <= usr_irq_req_08_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r[8] <= 1'b0;
		end else if (usr_irq_req_r[8] || usr_irq_req_08_cool_r != 4'd0) begin
			s_axi_rdata_r[8] <= 1'b1;
		end else begin
			s_axi_rdata_r[8] <= 1'b0;
		end
	end

	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_arready_r <= 1'b0;
		end else if (s_axi_arready_r) begin
			s_axi_arready_r <= 1'b0;
		end else if (s_axi_arvalid & (! s_axi_rvalid_r)) begin
			s_axi_arready_r <= 1'b1;
		end else begin
			s_axi_arready_r <= s_axi_arready_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
		end else if (s_axi_awready_r) begin
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
		end else if (s_axi_awvalid & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			s_axi_awready_r <= 1'b1;
			s_axi_wready_r <= 1'b1;
		end else begin
			s_axi_awready_r <= s_axi_awready_r;
			s_axi_wready_r <= s_axi_wready_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_bvalid_r <= 1'b0;
		end else if (s_axi_bvalid_r & s_axi_bready) begin
			s_axi_bvalid_r <= 1'b0;
		end else if (s_axi_awready_r) begin
			s_axi_bvalid_r <= 1'b1;
		end else begin
			s_axi_bvalid_r <= s_axi_bvalid_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rvalid_r <= 1'b0;
		end else if (s_axi_rvalid_r & s_axi_rready) begin
			s_axi_rvalid_r <= 1'b0;
		end else if (s_axi_arready_r) begin
			s_axi_rvalid_r <= 1'b1;
		end else begin
			s_axi_rvalid_r <= s_axi_rvalid_r;
		end
	end

	// output port connection
	assign usr_irq_req = usr_irq_req_r;

	assign s_axi_arready = s_axi_arready_r;
	assign s_axi_awready = s_axi_awready_r;
	assign s_axi_bresp   = 2'b00;
	assign s_axi_bvalid  = s_axi_bvalid_r;
	assign s_axi_rdata   = {23'd0, s_axi_rdata_r};
	assign s_axi_rresp   = 2'b00;
	assign s_axi_rvalid  = s_axi_rvalid_r;
	assign s_axi_wready  = s_axi_wready_r;
endmodule
