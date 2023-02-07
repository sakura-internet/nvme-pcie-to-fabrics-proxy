//------------------------------------------------------------------------------
// tb.v
//------------------------------------------------------------------------------
`timescale 10 ps / 1 ps

module tb;
	wire            clk50;
	wire            clk125;
	wire            clk156;
	wire            clk644;
	wire            aresetn;

	// clock generator
	clk_gen clk_gen(
		.o_clk50        (clk50),
		.o_clk125       (clk125),
		.o_clk156       (clk156),
		.o_clk644       (clk644),
		.aresetn        (aresetn)
	);

	wire    [8:0]   usr_irq_req;
	wire    [8:0]   usr_irq_ack;

	wire    [7:0]   s_axi_araddr;
	wire    [2:0]   s_axi_arprot;
	wire            s_axi_arready;
	wire            s_axi_arvalid;

	wire    [7:0]   s_axi_awaddr;
	wire    [2:0]   s_axi_awprot;
	wire            s_axi_awready;
	wire            s_axi_awvalid;

	wire            s_axi_bready;
	wire    [1:0]   s_axi_bresp;
	wire            s_axi_bvalid;

	wire    [31:0]  s_axi_rdata;
	wire            s_axi_rready;
	wire    [1:0]   s_axi_rresp;
	wire            s_axi_rvalid;

	wire    [31:0]  s_axi_wdata;
	wire            s_axi_wready;
	wire    [3:0]   s_axi_wstrb;
	wire            s_axi_wvalid;

	reg     [8:0]   usr_irq_ack_r;
	assign usr_irq_ack = usr_irq_ack_r;

	reg             s_axi_arvalid_r;
	reg             s_axi_awvalid_r;
	assign s_axi_araddr = 8'd0;
	assign s_axi_arprot = 2'd0;
	assign s_axi_awaddr = 8'd0;
	assign s_axi_awprot = 2'd0;
	assign s_axi_arvalid = s_axi_arvalid_r;
	assign s_axi_awvalid = s_axi_awvalid_r;

	reg             s_axi_bready_r;
	assign s_axi_bready = s_axi_bready_r;

	reg             s_axi_rready_r;
	reg     [31:0]  s_axi_wdata_r;
	reg             s_axi_wvalid_r;
	assign s_axi_rready = s_axi_rready_r;
	assign s_axi_wdata = s_axi_wdata_r;
	assign s_axi_wstrb = 4'b1111;
	assign s_axi_wvalid = s_axi_wvalid_r;

	msix_intc dut(
		.aclk(clk50),
		.aresetn(aresetn),

		// snoop port
		.usr_irq_req(usr_irq_req),       // output [8:0]
		.usr_irq_ack(usr_irq_ack),       // input [8:0]

		// s_axi
		.s_axi_araddr(s_axi_araddr),     // input [7:0]
		.s_axi_arprot(s_axi_arprot),     // input [2:0]
		.s_axi_arready(s_axi_arready),   // output
		.s_axi_arvalid(s_axi_arvalid),   // input

		.s_axi_awaddr(s_axi_awaddr),     // input [7:0]
		.s_axi_awprot(s_axi_awprot),     // input [2:0]
		.s_axi_awready(s_axi_awready),   // output
		.s_axi_awvalid(s_axi_awvalid),   // input

		.s_axi_bready(s_axi_bready),     // input
		.s_axi_bresp(s_axi_bresp),       // output [1:0]
		.s_axi_bvalid(s_axi_bvalid),     // output

		.s_axi_rdata(s_axi_rdata),       // output [31:0]
		.s_axi_rready(s_axi_rready),     // input
		.s_axi_rresp(s_axi_rresp),       // output [1:0]
		.s_axi_rvalid(s_axi_rvalid),     // output

		.s_axi_wdata(s_axi_wdata),       // input [31:0]
		.s_axi_wready(s_axi_wready),     // output
		.s_axi_wstrb(s_axi_wstrb),       // input [3:0]
		.s_axi_wvalid(s_axi_wvalid)      // input
	);

	// generate pseudo response for axilite bus
	integer i;
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(1, dut);

		@ (negedge aresetn);
		usr_irq_ack_r = 9'b000000000;
		s_axi_arvalid_r = 1'b0;
		s_axi_awvalid_r = 1'b0;
		s_axi_bready_r = 1'b0;
		s_axi_rready_r = 1'b0;
		s_axi_wdata_r = 32'd0;
		s_axi_wvalid_r = 1'b0;
		@ (posedge aresetn);
		
		for ( i = 0 ; i < 30 ; i = i + 1 ) begin
			@ ( posedge clk50 );
		end

		@ (posedge clk50);

		s_axi_awvalid_r = 1'b1;
		s_axi_wvalid_r = 1'b1;
		s_axi_wdata_r = 32'd1;
		@ (posedge clk50);
		while (! s_axi_awready) begin
			@ (posedge clk50);
		end
		s_axi_awvalid_r = 1'b0;
		s_axi_wvalid_r = 1'b0;
		s_axi_wdata_r = 32'd0;
		@ (posedge clk50);
		while (! s_axi_bvalid) begin
			@ (posedge clk50);
		end
		s_axi_bready_r = 1'b1;
		@ (posedge clk50);
		s_axi_bready_r = 1'b0;
		@ (posedge clk50);

		
		@ (posedge clk50);
		@ (posedge clk50);
		@ (posedge clk50);
		s_axi_arvalid_r = 1'b1;
		@ (posedge clk50);
		while (! s_axi_arready) begin
			@ (posedge clk50);
		end
		s_axi_arvalid_r = 1'b0;
	end

	// usr_irq_ack control
	integer j;
	initial begin
		@ (negedge aresetn);
		usr_irq_ack_r = 9'd0;
		@ (posedge aresetn);

		while (1'b1) begin
			if (usr_irq_req != 9'd0) begin
				@ (posedge clk50);
				@ (posedge clk50);
				@ (posedge clk50);
				@ (posedge clk50);
				usr_irq_ack_r = usr_irq_req;
				@ (posedge clk50);
				usr_irq_ack_r = 9'd0;
			end
			@ (posedge clk50);
		end
	end

	// limiting simulation time
	integer k;
	initial begin
		for ( k = 0 ; k < 10000 ; k = k + 1 ) begin
			@ ( posedge clk50 );
		end
		$stop;
	end
endmodule

module clk_gen(
	output o_clk50,
	output o_clk125,
	output o_clk156,
	output o_clk644,
	output aresetn
);
	reg clk50_r;
	reg clk125_r;
	reg clk156_r;
	reg clk644_r;
	reg aresetn_r;
	assign o_clk50 = clk50_r;
	assign o_clk125 = clk125_r;
	assign o_clk156 = clk156_r;
	assign o_clk644 = clk644_r;
	assign aresetn = aresetn_r;
	always begin
		clk50_r = 0;
		#(2000/2);
		clk50_r = 1;
		#(2000/2);
	end
	always begin
		clk125_r = 0;
		#(800/2);
		clk125_r = 1;
		#(800/2);
	end
	always begin
		clk156_r = 0;
		#(640/2);
		clk156_r = 1;
		#(640/2);
	end
	always begin
		clk644_r = 0;
		#(155.15/2);
		clk644_r = 1;
		#(155.15/2);
	end
	initial begin
		aresetn_r = 1'b1;
		#(1.24 * 2000);
		aresetn_r = 1'b0;
		#(18.9 * 2000);
		aresetn_r = 1'b1;
	end
endmodule
