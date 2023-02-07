`timescale 1 ps / 1 ps

module msi_intc(
	input aclk,
	input aresetn,

	// xdma irq interface
	output [4:0]  msi_vector_num,
	output        msi_request,
	input         msi_grant,

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

	reg    [4:0]  msi_vector_num_r;
	reg           msi_request_r;
	reg           msi_request_1d_r;
	reg    [3:0]  msi_request_cool_r;

	reg           s_axi_arready_r;
	reg           s_axi_awready_r;
	reg           s_axi_bvalid_r;
	reg           s_axi_rdata_r;
	reg           s_axi_rvalid_r;
	reg           s_axi_wready_r;

	// output port connection
	assign msi_vector_num = msi_vector_num_r;
	assign msi_request    = msi_request_r & (~msi_request_1d_r);

	assign s_axi_arready  = s_axi_arready_r;
	assign s_axi_awready  = s_axi_awready_r;
	assign s_axi_bresp    = 2'b00;
	assign s_axi_bvalid   = s_axi_bvalid_r;
	assign s_axi_rdata    = {31'd0, s_axi_rdata_r};
	assign s_axi_rresp    = 2'b00;
	assign s_axi_rvalid   = s_axi_rvalid_r;
	assign s_axi_wready   = s_axi_wready_r;

	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			msi_request_r <= 1'b0;
		end else if (msi_grant) begin
			msi_request_r <= 1'b0;
		end else if (s_axi_awvalid & (s_axi_awaddr == 8'd0) & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			msi_request_r <= 1'b1;
		end else begin
			msi_request_r <= msi_request_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			msi_request_1d_r <= 1'b0;
		end else begin
			msi_request_1d_r <= msi_request_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			msi_vector_num_r <= 5'b0;
		end else if (s_axi_awvalid & s_axi_wvalid & (! s_axi_bvalid_r)) begin
			msi_vector_num_r <= s_axi_wdata[4:0];
		end else begin
			msi_vector_num_r <= msi_vector_num_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			msi_request_cool_r <= 4'd0;
		end else if (msi_request_r & msi_grant) begin
			msi_request_cool_r <= 4'd15;
		end else if (msi_request_cool_r != 4'd0) begin
			msi_request_cool_r <= msi_request_cool_r - 4'd1;
		end else begin
			msi_request_cool_r <= msi_request_cool_r;
		end
	end
	always @ (posedge aclk or negedge aresetn) begin
		if (! aresetn) begin
			s_axi_rdata_r <= 1'b0;
		end else if (msi_request_r || msi_request_cool_r != 4'd0 || s_axi_bvalid_r) begin
			s_axi_rdata_r <= 1'b1;
		end else begin
			s_axi_rdata_r <= 1'b0;
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

endmodule
