`timescale 1 ns / 100 ps

module pl_system_wrapper(
    input         SYSCLK2_N,
    input         SYSCLK2_P,
    input         SYSCLK3_N,
    input         SYSCLK3_P,
    
    // pcie
    input         PCIE_PERSTN,
    //input         PEX_PWRBRKN,
    //input         PCIE_REFCLK0_P,
    //input         PCIE_REFCLK0_N,
    //input         PCIE_SYSCLK0_N,
    //input         PCIE_SYSCLK0_P,
    input         PCIE_REFCLK1_N,
    input         PCIE_REFCLK1_P,
    //input         PCIE_SYSCLK1_N,
    //input         PCIE_SYSCLK1_P,
    input  [15:0] PEX_RX_N,
    input  [15:0] PEX_RX_P,
    output [15:0] PEX_TX_N,
    output [15:0] PEX_TX_P,
    
    // QSFP28
    output        QSFP28_0_ACTIVITY_LED,
    output        QSFP28_0_STATUS_LEDG,
    output        QSFP28_0_STATUS_LEDY,
    //input  [3:0]  QSFP28_0_RX_N,
    //input  [3:0]  QSFP28_0_RX_P,
    //input  [3:0]  QSFP28_0_TX_N,
    //input  [3:0]  QSFP28_0_TX_P,
    //input         SYNCE_CLK_N,
    //input         SYNCE_CLK_P,
    //input         CLK_1588_N,
    //input         CLK_1588_P,
    
    // Serial Comm. via Alveo Programming Cable
    //input FPGA_UART0_RXD,
    //output FPGA_UART0_TXD,
    //input FPGA_UART1_RXD,
    //output FPGA_UART1_TXD,
    //input FPGA_UART2_RXD,
    //output FPGA_UART2_TXD,

    // Si5394B clock generator
    //output SI_RSTB,
    //input  SI_INTRB,
    //input  SI_PLL_LOCKB,
    //input  SI_IN_LOSB,
    //inout  I2C_SI5394_SCLK,
    //inout  I2C_SI5394_SDA,
    //output ETH_RECOVERED_CLK_N,
    //output ETH_RECOVERED_CLK_P,
    
    // satellite controller
    //input         FPGA_RXD_MSP,
    //output        FPGA_TXD_MSP,
    //inout         SYSMON_SDA,
    //inout         SYSMON_SCL,
    //output        SYSMON_ALRTN,
    output        HBM_CATTRIP
);
  wire pcie_axi_clk_snoop;
  wire pcie_axi_clk_hb;
  wire [2:0] gpio_led;
  pl_system pl_system_inst(
    .system_clk_clk_n(SYSCLK2_N),
    .system_clk_clk_p(SYSCLK2_P),
    .hbm_refclk_clk_n(SYSCLK3_N),
    .hbm_refclk_clk_p(SYSCLK3_P),
    .gpio_led_tri_o(gpio_led),
    .hbm_cattrip(HBM_CATTRIP),
    .pcie_axi_clk_snoop(pcie_axi_clk_snoop),
    .pcie_perst_n(PCIE_PERSTN),
    .pcie_refclk_clk_n(PCIE_REFCLK1_N),
    .pcie_refclk_clk_p(PCIE_REFCLK1_P),
    .pcie_rxn(PEX_RX_N),
    .pcie_rxp(PEX_RX_P),
    .pcie_txn(PEX_TX_N),
    .pcie_txp(PEX_TX_P)
  );
  gen_hb #(.FLIP_COUNT(32'd49999999)) ps_clk_hb_inst (
    .clk(pcie_axi_clk_snoop),
    .hb(pcie_axi_clk_hb)
  );
  assign QSFP28_0_ACTIVITY_LED = gpio_led[2];
  assign QSFP28_0_STATUS_LEDG = gpio_led[1];
  assign QSFP28_0_STATUS_LEDY = gpio_led[0];
endmodule
