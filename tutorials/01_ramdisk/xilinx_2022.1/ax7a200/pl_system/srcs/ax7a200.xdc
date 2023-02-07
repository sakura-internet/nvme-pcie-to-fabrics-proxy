################################################################################
# golden top xdc for ALINX ax7a200 development board
#  - port names are derived from "AX7A200 Carrier Board Schematic.pdf"
#    provided for ax7a200 board users by Alinx Electronic Technology Co.,Ltd.
################################################################################

################################################################################
# IOSTANDARD for configuration
################################################################################
set_property CFGBVS VCCO [current_design]; #
set_property CONFIG_VOLTAGE 3.3 [current_design]; #

################################################################################
# SPI configuration settings
################################################################################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]; #
set_property CONFIG_MODE SPIx4 [current_design]; #
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]; #
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]; #
#set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]; #

################################################################################
# clock definition
################################################################################
set_property -dict {PACKAGE_PIN R4 IOSTANDARD DIFF_SSTL15} [get_ports {SYS_CLK_P}]; #
set_property -dict {PACKAGE_PIN T4 IOSTANDARD DIFF_SSTL15} [get_ports {SYS_CLK_N}]; #
create_clock -period 5 [get_ports {SYS_CLK_P}]; #
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets sys_pll_inst/inst/clk_in1_sys_pll]; # enable this on DDR3 design

################################################################################
# DDR3 SDRAM
################################################################################
set_property -dict {PACKAGE_PIN V3 IOSTANDARD SSTL15} [get_ports {DDR3_addr[14]}]; #
set_property -dict {PACKAGE_PIN U1 IOSTANDARD SSTL15} [get_ports {DDR3_addr[13]}]; #
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD SSTL15} [get_ports {DDR3_addr[12]}]; #
set_property -dict {PACKAGE_PIN W2 IOSTANDARD SSTL15} [get_ports {DDR3_addr[11]}]; #
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD SSTL15} [get_ports {DDR3_addr[10]}]; #
set_property -dict {PACKAGE_PIN U2 IOSTANDARD SSTL15} [get_ports {DDR3_addr[9]}]; #
set_property -dict {PACKAGE_PIN V2 IOSTANDARD SSTL15} [get_ports {DDR3_addr[8]}]; #
set_property -dict {PACKAGE_PIN T1 IOSTANDARD SSTL15} [get_ports {DDR3_addr[7]}]; #
set_property -dict {PACKAGE_PIN W1 IOSTANDARD SSTL15} [get_ports {DDR3_addr[6]}]; #
set_property -dict {PACKAGE_PIN U3 IOSTANDARD SSTL15} [get_ports {DDR3_addr[5]}]; #
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD SSTL15} [get_ports {DDR3_addr[4]}]; #
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD SSTL15} [get_ports {DDR3_addr[3]}]; #
set_property -dict {PACKAGE_PIN AA5 IOSTANDARD SSTL15} [get_ports {DDR3_addr[2]}]; #
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD SSTL15} [get_ports {DDR3_addr[1]}]; #
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD SSTL15} [get_ports {DDR3_addr[0]}]; #
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD SSTL15} [get_ports {DDR3_ba[2]}]; #
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD SSTL15} [get_ports {DDR3_ba[1]}]; #
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD SSTL15} [get_ports {DDR3_ba[0]}]; #
set_property -dict {PACKAGE_PIN W4 IOSTANDARD SSTL15} [get_ports {DDR3_cas_n}]; #
set_property -dict {PACKAGE_PIN R3 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_ck_p}]; #
set_property -dict {PACKAGE_PIN R2 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_ck_n}]; #
set_property -dict {PACKAGE_PIN T5 IOSTANDARD SSTL15} [get_ports {DDR3_cke}]; #
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD SSTL15} [get_ports {DDR3_cs_n}]; #
set_property -dict {PACKAGE_PIN M5 IOSTANDARD SSTL15} [get_ports {DDR3_dm[3]}]; #
set_property -dict {PACKAGE_PIN M2 IOSTANDARD SSTL15} [get_ports {DDR3_dm[2]}]; #
set_property -dict {PACKAGE_PIN G2 IOSTANDARD SSTL15} [get_ports {DDR3_dm[1]}]; #
set_property -dict {PACKAGE_PIN D2 IOSTANDARD SSTL15} [get_ports {DDR3_dm[0]}]; #
set_property -dict {PACKAGE_PIN P2 IOSTANDARD SSTL15} [get_ports {DDR3_dq[31]}]; #
set_property -dict {PACKAGE_PIN P6 IOSTANDARD SSTL15} [get_ports {DDR3_dq[30]}]; #
set_property -dict {PACKAGE_PIN N5 IOSTANDARD SSTL15} [get_ports {DDR3_dq[29]}]; #
set_property -dict {PACKAGE_PIN M6 IOSTANDARD SSTL15} [get_ports {DDR3_dq[28]}]; #
set_property -dict {PACKAGE_PIN N2 IOSTANDARD SSTL15} [get_ports {DDR3_dq[27]}]; #
set_property -dict {PACKAGE_PIN R1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[26]}]; #
set_property -dict {PACKAGE_PIN N4 IOSTANDARD SSTL15} [get_ports {DDR3_dq[25]}]; #
set_property -dict {PACKAGE_PIN P1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[24]}]; #
set_property -dict {PACKAGE_PIN L5 IOSTANDARD SSTL15} [get_ports {DDR3_dq[23]}]; #
set_property -dict {PACKAGE_PIN J4 IOSTANDARD SSTL15} [get_ports {DDR3_dq[22]}]; #
set_property -dict {PACKAGE_PIN K6 IOSTANDARD SSTL15} [get_ports {DDR3_dq[21]}]; #
set_property -dict {PACKAGE_PIN K3 IOSTANDARD SSTL15} [get_ports {DDR3_dq[20]}]; #
set_property -dict {PACKAGE_PIN J6 IOSTANDARD SSTL15} [get_ports {DDR3_dq[19]}]; #
set_property -dict {PACKAGE_PIN L3 IOSTANDARD SSTL15} [get_ports {DDR3_dq[18]}]; #
set_property -dict {PACKAGE_PIN M3 IOSTANDARD SSTL15} [get_ports {DDR3_dq[17]}]; #
set_property -dict {PACKAGE_PIN L4 IOSTANDARD SSTL15} [get_ports {DDR3_dq[16]}]; #
set_property -dict {PACKAGE_PIN H4 IOSTANDARD SSTL15} [get_ports {DDR3_dq[15]}]; #
set_property -dict {PACKAGE_PIN K1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[14]}]; #
set_property -dict {PACKAGE_PIN J5 IOSTANDARD SSTL15} [get_ports {DDR3_dq[13]}]; #
set_property -dict {PACKAGE_PIN J1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[12]}]; #
set_property -dict {PACKAGE_PIN H5 IOSTANDARD SSTL15} [get_ports {DDR3_dq[11]}]; #
set_property -dict {PACKAGE_PIN H2 IOSTANDARD SSTL15} [get_ports {DDR3_dq[10]}]; #
set_property -dict {PACKAGE_PIN G3 IOSTANDARD SSTL15} [get_ports {DDR3_dq[9]}]; #
set_property -dict {PACKAGE_PIN H3 IOSTANDARD SSTL15} [get_ports {DDR3_dq[8]}]; #
set_property -dict {PACKAGE_PIN E2 IOSTANDARD SSTL15} [get_ports {DDR3_dq[7]}]; #
set_property -dict {PACKAGE_PIN B1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[6]}]; #
set_property -dict {PACKAGE_PIN F1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[5]}]; #
set_property -dict {PACKAGE_PIN B2 IOSTANDARD SSTL15} [get_ports {DDR3_dq[4]}]; #
set_property -dict {PACKAGE_PIN F3 IOSTANDARD SSTL15} [get_ports {DDR3_dq[3]}]; #
set_property -dict {PACKAGE_PIN A1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[2]}]; #
set_property -dict {PACKAGE_PIN G1 IOSTANDARD SSTL15} [get_ports {DDR3_dq[1]}]; #
set_property -dict {PACKAGE_PIN C2 IOSTANDARD SSTL15} [get_ports {DDR3_dq[0]}]; #
set_property -dict {PACKAGE_PIN P5 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_p[3]}]; #
set_property -dict {PACKAGE_PIN M1 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_p[2]}]; #
set_property -dict {PACKAGE_PIN K2 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_p[1]}]; #
set_property -dict {PACKAGE_PIN E1 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_p[0]}]; #
set_property -dict {PACKAGE_PIN P4 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_n[3]}]; #
set_property -dict {PACKAGE_PIN L1 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_n[2]}]; #
set_property -dict {PACKAGE_PIN J2 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_n[1]}]; #
set_property -dict {PACKAGE_PIN D1 IOSTANDARD DIFF_SSTL15} [get_ports {DDR3_dqs_n[0]}]; #
set_property -dict {PACKAGE_PIN U5 IOSTANDARD SSTL15} [get_ports {DDR3_odt}]; #
set_property -dict {PACKAGE_PIN V4 IOSTANDARD SSTL15} [get_ports {DDR3_ras_n}]; #
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS15} [get_ports {DDR3_reset_n}]; #
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD SSTL15} [get_ports {DDR3_we_n}]; #

################################################################################
# push switches (active LOW)
################################################################################
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {RESET}]; #
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {KEY1}]; #
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {KEY2}]; #
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {KEY3}]; #
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {KEY4}]; #

################################################################################
# LEDs
################################################################################
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS15} [get_ports {SOM_LED1}]; # Active HIGH
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports {LED1}]; # Active LOW
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {LED2}]; # Active LOW
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {LED3}]; # Active LOW
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {LED4}]; # Active LOW

################################################################################
# usb uart bridge (Silicon Lab CP2102-GM)
################################################################################
#set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {UART1_RX}]; #
#set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {UART1_TX}]; #

################################################################################
# i2c eeprom (Microchip 24LC04 8bit x 512word)
################################################################################
#set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {I2C_SCL}]; #
#set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {I2C_SDA}]; #

################################################################################
# Ethernet RGMII PHY (Micrel KSZ9031RNX)
################################################################################
#set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {ETH_RXD[3]}]; #
#set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {ETH_RXD[2]}]; #
#set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {ETH_RXD[1]}]; #
#set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports {ETH_RXD[0]}]; #
#set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {ETH_TXD[3]}]; #
#set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {ETH_TXD[2]}]; #
#set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {ETH_TXD[1]}]; #
#set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {ETH_TXD[0]}]; #

#set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports {ETH_MDC}]; #
#set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {ETH_MDIO}]; #

#set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {ETH_RESET}]; #
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {ETH_RXCK}]; #
#set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {ETH_TXCK}]; #

#set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports {ETH_RXCTL}]; #
#set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {ETH_TXCTL}]; #

#create_clock -period 8.000 [get_ports ETH_RXCK]
#set_false_path -reset_path -from [get_clocks -of_objects [get_pins refclk/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks ETH_RXCK]

################################################################################
# SD card slot
################################################################################
#set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports {sd_dclk}]; #
#set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {sd_ncs}]; #
#set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports {sd_mosi}]; #
#set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {sd_miso}]; #

################################################################################
# SFP cage
################################################################################
#set_property -dict {PACKAGE_PIN F6 IOSTANDARD DIFF_SSTL15} [get_ports {MGT_CLK0_P}]; #
#set_property -dict {PACKAGE_PIN E6 IOSTANDARD DIFF_SSTL15} [get_ports {MGT_CLK0_N}]; #
#create_clock -period 8 [get_ports {MGT_CLK0_P}]

#set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33} [get_ports {SFP1_IIC_SCL}]; #
#set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports {SFP1_IIC_SDA}]; #
#set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports {SFP2_IIC_SCL}]; #
#set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports {SFP2_IIC_SDA}]; #
#set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {SFP1_TX_DIS}]; #
#set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {SFP1_LOSS}]; #
#set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {SFP2_TX_DIS}]; #
#set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {SFP2_LOSS}]; #

################################################################################
# HDMI output (prefixed with "VOUT_" to fit xdc nomenclature)
# (Silicon Image / Lattice Semiconductor Sil9134)
################################################################################
#set_property -dict {PACKAGE_PIN Y22 IOSTANDARD LVCMOS33 DRIVE 16} [get_ports {VOUT_9134_CLK}]; #

#set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {VOUT_9134_nRESET}]; #
#set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {B15_L16_N_UNUSED}]; #

#set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[23]}]; #
#set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[22]}]; #
#set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[21]}]; #
#set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[20]}]; #
#set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[19]}]; #
#set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[18]}]; #
#set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[17]}]; #
#set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[16]}]; #
#set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[15]}]; #
#set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[14]}]; #
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[13]}]; #
#set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[12]}]; #
#set_property -dict {PACKAGE_PIN AB18 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[11]}]; #
#set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[10]}]; #
#set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[9]}]; #
#set_property -dict {PACKAGE_PIN W21 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[8]}]; #
#set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[7]}]; #
#set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[6]}]; #
#set_property -dict {PACKAGE_PIN Y21 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[5]}]; #
#set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[4]}]; #
#set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[3]}]; #
#set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[2]}]; #
#set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[1]}]; #
#set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_D[0]}]; #

#set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_DE}]; #
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_HS}]; #
#set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 IOB TRUE SLEW FAST DRIVE 12} [get_ports {VOUT_9134_VS}]; #

#set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports {VOUT_HDMI_SCL}]; #
#set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {VOUT_HDMI_SDA}]; #

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {vout_clk_OBUF}]

################################################################################
# HDMI input (prefixed with "VIN_" to fit xdc nomenclature)
################################################################################
#set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_CLK}]; #
#create_clock -period 6.734 -name VIN_9013_CLK -waveform {0.000 3.367} [get_ports {VIN_9013_CLK}]

#set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_nRESET}]; #

#set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[23]}]; #
#set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[22]}]; #
#set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[21]}]; #
#set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[20]}]; #
#set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[19]}]; #
#set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[18]}]; #
#set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[17]}]; #
#set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[16]}]; #
#set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[15]}]; #
#set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[14]}]; #
#set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[13]}]; #
#set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[12]}]; #
#set_property -dict {PACKAGE_PIN J22 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[11]}]; #
#set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[10]}]; #
#set_property -dict {PACKAGE_PIN K22 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[9]}]; #
#set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[8]}]; #
#set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[7]}]; #
#set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[6]}]; #
#set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[5]}]; #
#set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[4]}]; #
#set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[3]}]; #
#set_property -dict {PACKAGE_PIN L21 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[2]}]; #
#set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[1]}]; #
#set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_D[0]}]; #

#set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_DE}]; #
#set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_HS}]; #
#set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {VIN_9013_VS}]; #

################################################################################
# PCIe x2 endpoint
################################################################################
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {PCIE_PERST}]; #
set_false_path -from [get_ports PCIE_PERST]; #

set_property -dict {PACKAGE_PIN F10 IOSTANDARD DIFF_SSTL15} [get_ports {PCIE_CLK_P}]; #
set_property -dict {PACKAGE_PIN E10 IOSTANDARD DIFF_SSTL15} [get_ports {PCIE_CLK_N}]; #
create_clock -period 10.000 -name sys_clk [get_ports {PCIE_CLK_P}]; #
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets pl_system/clk_wiz_0/inst/clk_in1_PCIe_clk_wiz_0_0]; #

# settings below are specified from PCIe HIP you dont need to uncomment
#set_property -dict {PACKAGE_PIN B10} [get_ports {PCIE_RX1_P}]; #
#set_property -dict {PACKAGE_PIN A10} [get_ports {PCIE_RX1_N}]; #
#set_property -dict {PACKAGE_PIN D9} [get_ports {PCIE_RX0_P}]; #
#set_property -dict {PACKAGE_PIN C9} [get_ports {PCIE_RX0_N}]; #
#set_property -dict {PACKAGE_PIN B6} [get_ports {PCIE_TX1_P}]; #
#set_property -dict {PACKAGE_PIN A6} [get_ports {PCIE_TX1_N}]; #
#set_property -dict {PACKAGE_PIN D7} [get_ports {PCIE_TX0_P}]; #
#set_property -dict {PACKAGE_PIN C7} [get_ports {PCIE_TX0_N}]; #
