//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
//Date        : Thu Feb 17 07:46:43 2022
//Host        : hmmt32 running 64-bit Ubuntu 18.04.6 LTS
//Command     : generate_target pl_system_wrapper.bd
//Design      : pl_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pl_system_wrapper(
  input           SYS_CLK_P,
  input           SYS_CLK_N,
  // DDR3 SDRAM
  output  [14:0]  DDR3_addr,
  output  [2:0]   DDR3_ba,
  output          DDR3_cas_n,
  output          DDR3_ck_n,
  output          DDR3_ck_p,
  output          DDR3_cke,
  output          DDR3_cs_n,
  output  [3:0]   DDR3_dm,
  inout   [31:0]  DDR3_dq,
  inout   [3:0]   DDR3_dqs_n,
  inout   [3:0]   DDR3_dqs_p,
  output          DDR3_odt,
  output          DDR3_ras_n,
  output          DDR3_reset_n,
  output          DDR3_we_n,
  // push switches (active LOW)
  input           RESET,
  input           KEY1,
  input           KEY2,
  input           KEY3,
  input           KEY4,
  // PCIe
  input           PCIE_RX0_P,
  input           PCIE_RX0_N,
  input           PCIE_RX1_P,
  input           PCIE_RX1_N,
  output          PCIE_TX0_P,
  output          PCIE_TX0_N,
  output          PCIE_TX1_P,
  output          PCIE_TX1_N,
  input           PCIE_CLK_P,
  input           PCIE_CLK_N,
  input           PCIE_PERST,
  // LEDs
  output          SOM_LED1,  // active HIGH
  output          LED1,      // active LOW
  output          LED2,      // active LOW
  output          LED3,      // active LOW
  output          LED4       // active LOW
);

  wire clk_400;
  wire clk_200;
  wire clk_100;
  wire arst_n;
  wire sys_pll_locked;

  reg [26:0] SOM_LED1_cnt_r;

  // external port connection
  assign arst_n = RESET;
  assign SOM_LED1 = SOM_LED1_cnt_r[26];
  
  // terminate differential clock input and generate ddr system clock
  sys_pll sys_pll_inst
  (
    // Clock out ports
    .clk_out_400(clk_400),
    .clk_out_200(clk_200),
    .clk_out_100(clk_100),
    // Status and control signals
    .resetn(arst_n),
    .locked(sys_pll_locked),
    // Clock in ports
    .clk_in1_p(SYS_CLK_P),
    .clk_in1_n(SYS_CLK_N)
  );
  
  IBUFDS_GTE2 clk_buf_pcie_inst(
    .I(PCIE_CLK_P),
    .IB(PCIE_CLK_N),
    .CEB(1'b0),
    .O(pcie_clk),
    .ODIV2()
  );
  
  pl_system pl_system_inst(
    .clk_400(clk_400),
    .clk_200(clk_200),
    .clk_100(clk_100),
    .arst_n(sys_pll_locked),
    .gpio_led_tri_o({LED4, LED3, LED2, LED1}),
    .pcie_perst_n(PCIE_PERST),
    .pcie_refclk(pcie_clk),
    .pcie_rxp({PCIE_RX1_P, PCIE_RX0_P}),
    .pcie_rxn({PCIE_RX1_N, PCIE_RX0_N}),
    .pcie_txp({PCIE_TX1_P, PCIE_TX0_P}),
    .pcie_txn({PCIE_TX1_N, PCIE_TX0_N}),
    .DDR3_addr(DDR3_addr),       // output [14:0]
    .DDR3_ba(DDR3_ba),           // output [2:0]
    .DDR3_cas_n(DDR3_cas_n),     // output
    .DDR3_ck_n(DDR3_ck_n),       // output
    .DDR3_ck_p(DDR3_ck_p),       // output
    .DDR3_cke(DDR3_cke),         // output
    .DDR3_cs_n(DDR3_cs_n),       // output
    .DDR3_dm(DDR3_dm),           // output [3:0]
    .DDR3_dq(DDR3_dq),           // inout  [31:0]
    .DDR3_dqs_n(DDR3_dqs_n),     // inout  [3:0]
    .DDR3_dqs_p(DDR3_dqs_p),     // inout  [3:0]
    .DDR3_odt(DDR3_odt),         // output
    .DDR3_ras_n(DDR3_ras_n),     // output
    .DDR3_reset_n(DDR3_reset_n), // output
    .DDR3_we_n(DDR3_we_n)        // output
  );

  always @ (posedge clk_200 or negedge sys_pll_locked) begin
    if (! sys_pll_locked) begin
      SOM_LED1_cnt_r <= 27'd0;
    end else begin
      SOM_LED1_cnt_r <= SOM_LED1_cnt_r + 27'd1;
    end
  end

endmodule
