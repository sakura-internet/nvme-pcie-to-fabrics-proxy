`timescale 1 ns / 100 ps
module xdma_irqreg_remapper(
	input         aclk,
	input         aresetn,

	// s_axi
	input  [19:0] s_axil_araddr,
	input  [2:0]  s_axil_arprot,
	output        s_axil_arready,
	input         s_axil_arvalid,

	input  [19:0] s_axil_awaddr,
	input  [2:0]  s_axil_awprot,
	output        s_axil_awready,
	input         s_axil_awvalid,

	input         s_axil_bready,
	output [1:0]  s_axil_bresp,
	output        s_axil_bvalid,

	output [31:0] s_axil_rdata,
	input         s_axil_rready,
	output [1:0]  s_axil_rresp,
	output        s_axil_rvalid,

	input  [31:0] s_axil_wdata,
	output        s_axil_wready,
	input  [1:0]  s_axil_wstrb,
	input         s_axil_wvalid,

	// m_axi
	output [31:0] m_axil_araddr,
	output [2:0]  m_axil_arprot,
	input         m_axil_arready,
	output        m_axil_arvalid,

	output [31:0] m_axil_awaddr,
	output [2:0]  m_axil_awprot,
	input         m_axil_awready,
	output        m_axil_awvalid,

	output        m_axil_bready,
	input  [1:0]  m_axil_bresp,
	input         m_axil_bvalid,

	input  [31:0] m_axil_rdata,
	output        m_axil_rready,
	input  [1:0]  m_axil_rresp,
	input         m_axil_rvalid,

	output [31:0] m_axil_wdata,
	input         m_axil_wready,
	output [3:0]  m_axil_wstrb,
	output        m_axil_wvalid
);

	assign m_axil_araddr = {4'd0, s_axil_araddr[19:16], 8'd0, s_axil_araddr[15:0]};
	assign m_axil_arprot = s_axil_arprot;
	assign s_axil_arready = m_axil_arready;
	assign m_axil_arvalid = s_axil_arvalid;

	assign m_axil_awaddr = {4'd0, s_axil_awaddr[19:16], 8'd0, s_axil_awaddr[15:0]};
	assign m_axil_awprot = s_axil_awprot;
	assign s_axil_awready = m_axil_awready;
	assign m_axil_awvalid = s_axil_awvalid;

	assign m_axil_bready = s_axil_bready;
	assign s_axil_bresp = m_axil_bresp;
	assign s_axil_bvalid = m_axil_bvalid;

	assign s_axil_rdata = m_axil_rdata;
	assign m_axil_rready = s_axil_rready;
	assign s_axil_rresp = m_axil_rresp;
	assign s_axil_rvalid = m_axil_rvalid;

	assign s_axil_wdata = m_axil_wdata;
	assign m_axil_wready = s_axil_wready;
	assign s_axil_wstrb = 4'b1111;
	assign s_axil_wvalid = m_axil_wvalid;
endmodule
