
################################################################
# This is a generated script based on design: pl_system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source pl_system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# msix_intc, xdma_irqreg_remapper

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcu50-fsvh2104-2-e
   set_property BOARD_PART xilinx.com:au50:part0:1.3 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name pl_system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:util_reduced_logic:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:system_management_wiz:1.3\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_firewall:1.2\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:xdma:4.1\
xilinx.com:ip:hbm:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
msix_intc\
xdma_irqreg_remapper\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: sdram
proc create_hier_cell_sdram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_sdram() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_refclk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_00


  # Create pins
  create_bd_pin -dir I arst_n
  create_bd_pin -dir I -type clk ctrl_clk
  create_bd_pin -dir I -type clk data_clk
  create_bd_pin -dir O hbm_cattrip

  # Create instance: hbm, and set properties
  set hbm [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm ]
  set_property -dict [ list \
   CONFIG.HBM_MMCM_FBOUT_MULT0 {4} \
   CONFIG.USER_APB_EN {false} \
   CONFIG.USER_AUTO_POPULATE {yes} \
   CONFIG.USER_AXI_CLK_FREQ {250} \
   CONFIG.USER_AXI_INPUT_CLK_FREQ {250} \
   CONFIG.USER_AXI_INPUT_CLK_NS {4.000} \
   CONFIG.USER_AXI_INPUT_CLK_PS {4000} \
   CONFIG.USER_AXI_INPUT_CLK_XDC {4.000} \
   CONFIG.USER_CLK_SEL_LIST0 {AXI_01_ACLK} \
   CONFIG.USER_MC_ENABLE_00 {TRUE} \
   CONFIG.USER_MC_ENABLE_01 {TRUE} \
   CONFIG.USER_MC_ENABLE_02 {FALSE} \
   CONFIG.USER_MC_ENABLE_03 {FALSE} \
   CONFIG.USER_MC_ENABLE_04 {FALSE} \
   CONFIG.USER_MC_ENABLE_05 {FALSE} \
   CONFIG.USER_MC_ENABLE_06 {FALSE} \
   CONFIG.USER_MC_ENABLE_07 {FALSE} \
   CONFIG.USER_SAXI_01 {true} \
   CONFIG.USER_SAXI_02 {true} \
   CONFIG.USER_SAXI_03 {true} \
   CONFIG.USER_SAXI_04 {false} \
   CONFIG.USER_SAXI_05 {false} \
   CONFIG.USER_SAXI_06 {false} \
   CONFIG.USER_SAXI_07 {false} \
   CONFIG.USER_SAXI_08 {false} \
   CONFIG.USER_SAXI_09 {false} \
   CONFIG.USER_SAXI_10 {false} \
   CONFIG.USER_SAXI_11 {false} \
   CONFIG.USER_SAXI_12 {false} \
   CONFIG.USER_SAXI_13 {false} \
   CONFIG.USER_SAXI_14 {false} \
   CONFIG.USER_SAXI_15 {false} \
   CONFIG.USER_SWITCH_ENABLE_00 {FALSE} \
 ] $hbm

  # Create instance: ibufds, and set properties
  set ibufds [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 ibufds ]

  # Create instance: intx, and set properties
  set intx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {4} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx

  # Create interface connections
  connect_bd_intf_net -intf_net hbm_refclk [get_bd_intf_pins hbm_refclk] [get_bd_intf_pins ibufds/CLK_IN_D]
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins hbm/SAXI_00] [get_bd_intf_pins intx/M00_AXI]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins hbm/SAXI_01] [get_bd_intf_pins intx/M01_AXI]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins hbm/SAXI_02] [get_bd_intf_pins intx/M02_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins hbm/SAXI_03] [get_bd_intf_pins intx/M03_AXI]
  connect_bd_intf_net -intf_net s_axi_00_1 [get_bd_intf_pins s_axi_00] [get_bd_intf_pins intx/S00_AXI]

  # Create port connections
  connect_bd_net -net ACLK_1 [get_bd_pins data_clk] [get_bd_pins hbm/AXI_00_ACLK] [get_bd_pins hbm/AXI_01_ACLK] [get_bd_pins hbm/AXI_02_ACLK] [get_bd_pins hbm/AXI_03_ACLK] [get_bd_pins intx/ACLK] [get_bd_pins intx/M00_ACLK] [get_bd_pins intx/M01_ACLK] [get_bd_pins intx/M02_ACLK] [get_bd_pins intx/M03_ACLK] [get_bd_pins intx/S00_ACLK]
  connect_bd_net -net APB_0_PCLK_1 [get_bd_pins ctrl_clk] [get_bd_pins hbm/APB_0_PCLK]
  connect_bd_net -net hbm_DRAM_0_STAT_CATTRIP [get_bd_pins hbm_cattrip] [get_bd_pins hbm/DRAM_0_STAT_CATTRIP]
  connect_bd_net -net ibufds_IBUF_OUT [get_bd_pins hbm/HBM_REF_CLK_0] [get_bd_pins ibufds/IBUF_OUT]
  connect_bd_net -net srst_n [get_bd_pins arst_n] [get_bd_pins hbm/APB_0_PRESET_N] [get_bd_pins hbm/AXI_00_ARESET_N] [get_bd_pins hbm/AXI_01_ARESET_N] [get_bd_pins hbm/AXI_02_ARESET_N] [get_bd_pins hbm/AXI_03_ARESET_N] [get_bd_pins intx/ARESETN] [get_bd_pins intx/M00_ARESETN] [get_bd_pins intx/M01_ARESETN] [get_bd_pins intx/M02_ARESETN] [get_bd_pins intx/M03_ARESETN] [get_bd_pins intx/S00_ARESETN]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: pcie_system
proc create_hier_cell_pcie_system { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_pcie_system() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 serial


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk axi_clk
  create_bd_pin -dir O axi_clk_snoop
  create_bd_pin -dir I -type rst pcie_perst_n

  # Create instance: const_high, and set properties
  set const_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_high ]

  # Create instance: fw_in, and set properties
  set fw_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 fw_in ]

  # Create instance: fw_out, and set properties
  set fw_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 fw_out ]

  # Create instance: ibuf_refclk, and set properties
  set ibuf_refclk [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 ibuf_refclk ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {pcie_refclk} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $ibuf_refclk

  # Create instance: intc, and set properties
  set block_name msix_intc
  set block_cell_name intc
  if { [catch {set intc [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $intc eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: intx_fw, and set properties
  set intx_fw [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx_fw ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {3} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx_fw

  # Create instance: intx_in, and set properties
  set intx_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx_in ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {3} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx_in

  # Create instance: intx_out, and set properties
  set intx_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx_out ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {0} \
 ] $intx_out

  # Create instance: pcie, and set properties
  set pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 pcie ]
  set_property -dict [ list \
   CONFIG.PCIE_BOARD_INTERFACE {pci_express_x16} \
   CONFIG.PF0_DEVICE_ID_mqdma {903F} \
   CONFIG.PF0_SRIOV_VF_DEVICE_ID {A03F} \
   CONFIG.PF1_SRIOV_VF_DEVICE_ID {A13F} \
   CONFIG.PF2_DEVICE_ID_mqdma {923F} \
   CONFIG.PF2_SRIOV_VF_DEVICE_ID {A23F} \
   CONFIG.PF3_DEVICE_ID_mqdma {933F} \
   CONFIG.PF3_SRIOV_VF_DEVICE_ID {A33F} \
   CONFIG.PHY_LP_TXPRESET {5} \
   CONFIG.SYS_RST_N_BOARD_INTERFACE {pcie_perstn} \
   CONFIG.axi_addr_width {52} \
   CONFIG.axi_data_width {512_bit} \
   CONFIG.axibar2pciebar_0 {0x0000000000000000} \
   CONFIG.axisten_freq {250} \
   CONFIG.bar0_indicator {0} \
   CONFIG.bar2_indicator {1} \
   CONFIG.bar_indicator {BAR_3:2} \
   CONFIG.bridge_burst {true} \
   CONFIG.c_s_axi_supports_narrow_burst {true} \
   CONFIG.coreclk_freq {500} \
   CONFIG.en_bridge_slv {true} \
   CONFIG.en_gt_selection {true} \
   CONFIG.enable_auto_rxeq {True} \
   CONFIG.enable_pcie_debug {False} \
   CONFIG.functional_mode {AXI_Bridge} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pcie_blk_locn {PCIE4C_X1Y0} \
   CONFIG.pciebar2axibar_0 {0x00000000A0080000} \
   CONFIG.pf0_bar0_64bit {true} \
   CONFIG.pf0_bar0_size {128} \
   CONFIG.pf0_bar2_64bit {true} \
   CONFIG.pf0_bar2_enabled {true} \
   CONFIG.pf0_bar2_size {128} \
   CONFIG.pf0_bar4_enabled {false} \
   CONFIG.pf0_base_class_menu {Mass_storage_controller} \
   CONFIG.pf0_class_code {010802} \
   CONFIG.pf0_class_code_base {01} \
   CONFIG.pf0_class_code_interface {02} \
   CONFIG.pf0_class_code_sub {08} \
   CONFIG.pf0_device_id {903F} \
   CONFIG.pf0_interrupt_pin {NONE} \
   CONFIG.pf0_msi_enabled {false} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1:0} \
   CONFIG.pf0_msix_cap_pba_offset {00008FE0} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1:0} \
   CONFIG.pf0_msix_cap_table_offset {00008000} \
   CONFIG.pf0_msix_cap_table_size {01F} \
   CONFIG.pf0_msix_enabled {true} \
   CONFIG.pf0_sub_class_interface_menu {Other_mass_storage_controller} \
   CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X16} \
   CONFIG.plltype {QPLL1} \
   CONFIG.select_quad {GTY_Quad_227} \
   CONFIG.vdm_en {true} \
   CONFIG.xdma_axilite_slave {true} \
   CONFIG.xdma_num_usr_irq {9} \
 ] $pcie

  # Create instance: remapper, and set properties
  set block_name xdma_irqreg_remapper
  set block_cell_name remapper
  if { [catch {set remapper [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $remapper eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: rstgen_ep_ctl, and set properties
  set rstgen_ep_ctl [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rstgen_ep_ctl ]

  # Create instance: rstgen_ep_data, and set properties
  set rstgen_ep_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rstgen_ep_data ]

  # Create interface connections
  connect_bd_intf_net -intf_net fw_in_M_AXI [get_bd_intf_pins fw_in/M_AXI] [get_bd_intf_pins intx_in/S00_AXI]
  connect_bd_intf_net -intf_net fw_out_M_AXI [get_bd_intf_pins m_axi] [get_bd_intf_pins fw_out/M_AXI]
  connect_bd_intf_net -intf_net intx_fw_M00_AXI [get_bd_intf_pins fw_in/S_AXI] [get_bd_intf_pins intx_fw/M00_AXI]
  connect_bd_intf_net -intf_net intx_fw_M01_AXI [get_bd_intf_pins fw_in/S_AXI_CTL] [get_bd_intf_pins intx_fw/M01_AXI]
  connect_bd_intf_net -intf_net intx_fw_M02_AXI [get_bd_intf_pins fw_out/S_AXI_CTL] [get_bd_intf_pins intx_fw/M02_AXI]
  connect_bd_intf_net -intf_net intx_in_M00_AXI [get_bd_intf_pins intx_in/M00_AXI] [get_bd_intf_pins pcie/S_AXI_B]
  connect_bd_intf_net -intf_net intx_in_M01_AXI [get_bd_intf_pins intx_in/M01_AXI] [get_bd_intf_pins remapper/s_axil]
  connect_bd_intf_net -intf_net intx_in_M02_AXI [get_bd_intf_pins intc/s_axi] [get_bd_intf_pins intx_in/M02_AXI]
  connect_bd_intf_net -intf_net intx_out_M00_AXI [get_bd_intf_pins fw_out/S_AXI] [get_bd_intf_pins intx_out/M00_AXI]
  connect_bd_intf_net -intf_net pcie_M_AXI_B [get_bd_intf_pins intx_out/S00_AXI] [get_bd_intf_pins pcie/M_AXI_B]
  connect_bd_intf_net -intf_net pcie_pcie_mgt [get_bd_intf_pins serial] [get_bd_intf_pins pcie/pcie_mgt]
  connect_bd_intf_net -intf_net pcie_refclk [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins ibuf_refclk/CLK_IN_D]
  connect_bd_intf_net -intf_net remapper_m_axil [get_bd_intf_pins pcie/S_AXI_LITE] [get_bd_intf_pins remapper/m_axil]
  connect_bd_intf_net -intf_net s_axi [get_bd_intf_pins s_axi] [get_bd_intf_pins intx_fw/S00_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins fw_in/aresetn] [get_bd_pins fw_out/aresetn] [get_bd_pins intx_fw/ARESETN] [get_bd_pins intx_fw/M00_ARESETN] [get_bd_pins intx_fw/M01_ARESETN] [get_bd_pins intx_fw/M02_ARESETN] [get_bd_pins intx_fw/S00_ARESETN] [get_bd_pins intx_in/ARESETN] [get_bd_pins intx_in/S00_ARESETN] [get_bd_pins intx_out/ARESETN] [get_bd_pins intx_out/M00_ARESETN]
  connect_bd_net -net axi_clk [get_bd_pins axi_clk] [get_bd_pins fw_in/aclk] [get_bd_pins fw_out/aclk] [get_bd_pins intx_fw/ACLK] [get_bd_pins intx_fw/M00_ACLK] [get_bd_pins intx_fw/M01_ACLK] [get_bd_pins intx_fw/M02_ACLK] [get_bd_pins intx_fw/S00_ACLK] [get_bd_pins intx_in/ACLK] [get_bd_pins intx_in/S00_ACLK] [get_bd_pins intx_out/ACLK] [get_bd_pins intx_out/M00_ACLK]
  connect_bd_net -net const_high_dout [get_bd_pins const_high/dout] [get_bd_pins rstgen_ep_ctl/aux_reset_in] [get_bd_pins rstgen_ep_ctl/dcm_locked] [get_bd_pins rstgen_ep_data/aux_reset_in] [get_bd_pins rstgen_ep_data/dcm_locked]
  connect_bd_net -net ibuf_refclk_IBUF_DS_ODIV2 [get_bd_pins ibuf_refclk/IBUF_DS_ODIV2] [get_bd_pins pcie/sys_clk]
  connect_bd_net -net ibuf_refclk_IBUF_OUT [get_bd_pins ibuf_refclk/IBUF_OUT] [get_bd_pins pcie/sys_clk_gt]
  connect_bd_net -net intc_usr_irq_req [get_bd_pins intc/usr_irq_req] [get_bd_pins pcie/usr_irq_req]
  connect_bd_net -net pcie_axi_aclk [get_bd_pins axi_clk_snoop] [get_bd_pins intc/aclk] [get_bd_pins intx_in/M00_ACLK] [get_bd_pins intx_in/M01_ACLK] [get_bd_pins intx_in/M02_ACLK] [get_bd_pins intx_out/S00_ACLK] [get_bd_pins pcie/axi_aclk] [get_bd_pins remapper/aclk] [get_bd_pins rstgen_ep_ctl/slowest_sync_clk] [get_bd_pins rstgen_ep_data/slowest_sync_clk]
  connect_bd_net -net pcie_axi_aresetn [get_bd_pins pcie/axi_aresetn] [get_bd_pins rstgen_ep_data/ext_reset_in]
  connect_bd_net -net pcie_axi_ctl_aresetn [get_bd_pins pcie/axi_ctl_aresetn] [get_bd_pins rstgen_ep_ctl/ext_reset_in]
  connect_bd_net -net pcie_perst_n [get_bd_pins pcie_perst_n] [get_bd_pins pcie/sys_rst_n]
  connect_bd_net -net pcie_usr_irq_ack [get_bd_pins intc/usr_irq_ack] [get_bd_pins pcie/usr_irq_ack]
  connect_bd_net -net rstgen_ep_ctl_peripheral_aresetn [get_bd_pins intx_in/M01_ARESETN] [get_bd_pins remapper/aresetn] [get_bd_pins rstgen_ep_ctl/peripheral_aresetn]
  connect_bd_net -net rstgen_ep_data_peripheral_aresetn [get_bd_pins intc/aresetn] [get_bd_pins intx_in/M00_ARESETN] [get_bd_pins intx_in/M02_ARESETN] [get_bd_pins intx_out/S00_ARESETN] [get_bd_pins rstgen_ep_data/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mb_system
proc create_hier_cell_mb_system { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mb_system() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk m_axi_clk
  create_bd_pin -dir I -type clk mb_clk

  # Create instance: const_high, and set properties
  set const_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_high ]

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: intc, and set properties
  set intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 intc ]
  set_property -dict [ list \
   CONFIG.C_HAS_FAST {1} \
 ] $intc

  # Create instance: intx, and set properties
  set intx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {4} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create instance: mb, and set properties
  set mb [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 mb ]
  set_property -dict [ list \
   CONFIG.C_ADDR_SIZE {52} \
   CONFIG.C_ADDR_TAG_BITS {0} \
   CONFIG.C_AREA_OPTIMIZED {1} \
   CONFIG.C_CACHE_BYTE_SIZE {4096} \
   CONFIG.C_DATA_SIZE {32} \
   CONFIG.C_DCACHE_ADDR_TAG {0} \
   CONFIG.C_DCACHE_BYTE_SIZE {4096} \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
   CONFIG.C_MMU_DTLB_SIZE {2} \
   CONFIG.C_MMU_ITLB_SIZE {1} \
   CONFIG.C_MMU_ZONES {2} \
   CONFIG.C_M_AXI_DC_ADDR_WIDTH {52} \
   CONFIG.C_M_AXI_DP_ADDR_WIDTH {52} \
   CONFIG.C_USE_BARREL {1} \
   CONFIG.C_USE_HW_MUL {1} \
   CONFIG.C_USE_MSR_INSTR {1} \
   CONFIG.C_USE_PCMP_INSTR {1} \
   CONFIG.C_USE_REORDER_INSTR {0} \
   CONFIG.G_TEMPLATE_LIST {8} \
 ] $mb

  # Create instance: mdm, and set properties
  set mdm [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm ]
  set_property -dict [ list \
   CONFIG.C_ADDR_SIZE {32} \
   CONFIG.C_M_AXI_ADDR_WIDTH {32} \
   CONFIG.C_USE_UART {1} \
 ] $mdm

  # Create instance: rstgen, and set properties
  set rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rstgen ]

  # Create instance: timer, and set properties
  set timer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 timer ]
  set_property -dict [ list \
   CONFIG.enable_timer2 {0} \
 ] $timer

  # Create interface connections
  connect_bd_intf_net -intf_net dlmb_bram_if_cntlr_BRAM_PORT [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net dlmb_v10_LMB_SI_0 [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net ilmb_bram_if_cntlr_BRAM_PORT [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net ilmb_v10_LMB_SI_0 [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net intc_interrupt [get_bd_intf_pins intc/interrupt] [get_bd_intf_pins mb/INTERRUPT]
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intx/M00_AXI] [get_bd_intf_pins mdm/S_AXI]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins intc/s_axi] [get_bd_intf_pins intx/M01_AXI]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins intx/M02_AXI] [get_bd_intf_pins timer/S_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins m_axi] [get_bd_intf_pins intx/M03_AXI]
  connect_bd_intf_net -intf_net mb_DLMB [get_bd_intf_pins dlmb_v10/LMB_M] [get_bd_intf_pins mb/DLMB]
  connect_bd_intf_net -intf_net mb_ILMB [get_bd_intf_pins ilmb_v10/LMB_M] [get_bd_intf_pins mb/ILMB]
  connect_bd_intf_net -intf_net mb_M_AXI_DP [get_bd_intf_pins intx/S00_AXI] [get_bd_intf_pins mb/M_AXI_DP]
  connect_bd_intf_net -intf_net mdm_MBDEBUG_0 [get_bd_intf_pins mb/DEBUG] [get_bd_intf_pins mdm/MBDEBUG_0]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx/M03_ARESETN] [get_bd_pins rstgen/ext_reset_in]
  connect_bd_net -net const_high_dout [get_bd_pins const_high/dout] [get_bd_pins rstgen/aux_reset_in] [get_bd_pins rstgen/dcm_locked]
  connect_bd_net -net m_axi_aclk [get_bd_pins m_axi_clk] [get_bd_pins intx/M03_ACLK]
  connect_bd_net -net mb_clk [get_bd_pins mb_clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk] [get_bd_pins intc/processor_clk] [get_bd_pins intc/s_axi_aclk] [get_bd_pins intx/ACLK] [get_bd_pins intx/M00_ACLK] [get_bd_pins intx/M01_ACLK] [get_bd_pins intx/M02_ACLK] [get_bd_pins intx/S00_ACLK] [get_bd_pins mb/Clk] [get_bd_pins mdm/S_AXI_ACLK] [get_bd_pins rstgen/slowest_sync_clk] [get_bd_pins timer/s_axi_aclk]
  connect_bd_net -net mdm_1_Debug_SYS_Rst [get_bd_pins mdm/Debug_SYS_Rst] [get_bd_pins rstgen/mb_debug_sys_rst]
  connect_bd_net -net rstgen_bus_struct_reset [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst] [get_bd_pins rstgen/bus_struct_reset]
  connect_bd_net -net rstgen_interconnect_aresetn [get_bd_pins intx/ARESETN] [get_bd_pins rstgen/interconnect_aresetn]
  connect_bd_net -net rstgen_mb_reset [get_bd_pins intc/processor_rst] [get_bd_pins mb/Reset] [get_bd_pins rstgen/mb_reset]
  connect_bd_net -net rstgen_peripheral_aresetn [get_bd_pins intc/s_axi_aresetn] [get_bd_pins intx/M00_ARESETN] [get_bd_pins intx/M01_ARESETN] [get_bd_pins intx/M02_ARESETN] [get_bd_pins intx/S00_ARESETN] [get_bd_pins mdm/S_AXI_ARESETN] [get_bd_pins rstgen/peripheral_aresetn] [get_bd_pins timer/s_axi_aresetn]
  connect_bd_net -net timer_interrupt [get_bd_pins intc/intr] [get_bd_pins timer/interrupt]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: intx
proc create_hier_cell_intx { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_intx() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk clk

  # Create instance: intx_core, and set properties
  set intx_core [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx_core ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.M04_HAS_REGSLICE {1} \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {1} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.S01_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx_core

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins intx_core/S00_AXI]
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins intx_core/M00_AXI]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins intx_core/M01_AXI]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins intx_core/M02_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins intx_core/M03_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx_core/ARESETN] [get_bd_pins intx_core/M00_ARESETN] [get_bd_pins intx_core/M01_ARESETN] [get_bd_pins intx_core/M02_ARESETN] [get_bd_pins intx_core/M03_ARESETN] [get_bd_pins intx_core/S00_ARESETN]
  connect_bd_net -net clk [get_bd_pins clk] [get_bd_pins intx_core/ACLK] [get_bd_pins intx_core/M00_ACLK] [get_bd_pins intx_core/M01_ACLK] [get_bd_pins intx_core/M02_ACLK] [get_bd_pins intx_core/M03_ACLK] [get_bd_pins intx_core/S00_ACLK]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gpio
proc create_hier_cell_gpio { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gpio() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk clk

  # Create instance: intx, and set properties
  set intx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx

  # Create instance: led, and set properties
  set led [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 led ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {3} \
 ] $led

  # Create instance: system_management_wiz, and set properties
  set system_management_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz:1.3 system_management_wiz ]

  # Create interface connections
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intx/M00_AXI] [get_bd_intf_pins led/S_AXI]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins intx/M01_AXI] [get_bd_intf_pins system_management_wiz/S_AXI_LITE]
  connect_bd_intf_net -intf_net led_GPIO [get_bd_intf_pins led] [get_bd_intf_pins led/GPIO]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins intx/S00_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx/ARESETN] [get_bd_pins intx/M00_ARESETN] [get_bd_pins intx/M01_ARESETN] [get_bd_pins intx/S00_ARESETN] [get_bd_pins led/s_axi_aresetn] [get_bd_pins system_management_wiz/s_axi_aresetn]
  connect_bd_net -net clk [get_bd_pins clk] [get_bd_pins intx/ACLK] [get_bd_pins intx/M00_ACLK] [get_bd_pins intx/M01_ACLK] [get_bd_pins intx/S00_ACLK] [get_bd_pins led/s_axi_aclk] [get_bd_pins system_management_wiz/s_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clk_gen
proc create_hier_cell_clk_gen { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clk_gen() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 system_clk


  # Create pins
  create_bd_pin -dir O -type rst arst_n
  create_bd_pin -dir O -type clk ctrl_clk
  create_bd_pin -dir O -type clk data_clk
  create_bd_pin -dir I -type rst pcie_perst_n

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {106.311} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {160.000} \
   CONFIG.CLKOUT2_JITTER {115.831} \
   CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {cmc_clk} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {7.500} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz

  # Create instance: const_high, and set properties
  set const_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_high ]

  # Create instance: rst_and, and set properties
  set rst_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 rst_and ]
  set_property -dict [ list \
   CONFIG.C_SIZE {1} \
 ] $rst_and

  # Create instance: rstgen, and set properties
  set rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rstgen ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $rstgen

  # Create interface connections
  connect_bd_intf_net -intf_net cmc_clk_1 [get_bd_intf_pins system_clk] [get_bd_intf_pins clk_wiz/CLK_IN1_D]

  # Create port connections
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins data_clk] [get_bd_pins clk_wiz/clk_out1]
  connect_bd_net -net clk_wiz_clk_out2 [get_bd_pins ctrl_clk] [get_bd_pins clk_wiz/clk_out2] [get_bd_pins rstgen/slowest_sync_clk]
  connect_bd_net -net clk_wiz_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rstgen/dcm_locked]
  connect_bd_net -net const_high_dout [get_bd_pins const_high/dout] [get_bd_pins rstgen/aux_reset_in]
  connect_bd_net -net pcie_perst_n [get_bd_pins pcie_perst_n] [get_bd_pins clk_wiz/resetn] [get_bd_pins rstgen/ext_reset_in]
  connect_bd_net -net rstgen_interconnect_aresetn [get_bd_pins rst_and/Op1] [get_bd_pins rstgen/interconnect_aresetn]
  connect_bd_net -net util_reduced_logic_0_Res [get_bd_pins arst_n] [get_bd_pins rst_and/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: bar0
proc create_hier_cell_bar0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_bar0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mb_s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 pcie_m_axi


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk clk

  # Create instance: bram, and set properties
  set bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 bram ]
  set_property -dict [ list \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $bram

  # Create instance: mb_bramc, and set properties
  set mb_bramc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 mb_bramc ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $mb_bramc

  # Create instance: pcie_bramc, and set properties
  set pcie_bramc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 pcie_bramc ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $pcie_bramc

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_bar0_BRAM_PORTA [get_bd_intf_pins bram/BRAM_PORTA] [get_bd_intf_pins mb_bramc/BRAM_PORTA]
  connect_bd_intf_net -intf_net mb_s_axi [get_bd_intf_pins mb_s_axi] [get_bd_intf_pins mb_bramc/S_AXI]
  connect_bd_intf_net -intf_net pcie_bramc_BRAM_PORTA [get_bd_intf_pins bram/BRAM_PORTB] [get_bd_intf_pins pcie_bramc/BRAM_PORTA]
  connect_bd_intf_net -intf_net pcie_m_axi [get_bd_intf_pins pcie_m_axi] [get_bd_intf_pins pcie_bramc/S_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins mb_bramc/s_axi_aresetn] [get_bd_pins pcie_bramc/s_axi_aresetn]
  connect_bd_net -net clk [get_bd_pins clk] [get_bd_pins mb_bramc/s_axi_aclk] [get_bd_pins pcie_bramc/s_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gpio_led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_led ]

  set hbm_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_refclk ]

  set pcie [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk

  set system_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 system_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $system_clk


  # Create ports
  set hbm_cattrip [ create_bd_port -dir O hbm_cattrip ]
  set pcie_axi_clk_snoop [ create_bd_port -dir O pcie_axi_clk_snoop ]
  set pcie_perst_n [ create_bd_port -dir I -type rst pcie_perst_n ]

  # Create instance: bar0
  create_hier_cell_bar0 [current_bd_instance .] bar0

  # Create instance: clk_gen
  create_hier_cell_clk_gen [current_bd_instance .] clk_gen

  # Create instance: gpio
  create_hier_cell_gpio [current_bd_instance .] gpio

  # Create instance: intx
  create_hier_cell_intx [current_bd_instance .] intx

  # Create instance: mb_system
  create_hier_cell_mb_system [current_bd_instance .] mb_system

  # Create instance: pcie_system
  create_hier_cell_pcie_system [current_bd_instance .] pcie_system

  # Create instance: sdram
  create_hier_cell_sdram [current_bd_instance .] sdram

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins intx/S00_AXI] [get_bd_intf_pins mb_system/m_axi]
  connect_bd_intf_net -intf_net gpio_led [get_bd_intf_ports gpio_led] [get_bd_intf_pins gpio/led]
  connect_bd_intf_net -intf_net hbm_refclk [get_bd_intf_ports hbm_refclk] [get_bd_intf_pins sdram/hbm_refclk]
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intx/M00_AXI] [get_bd_intf_pins pcie_system/s_axi]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins bar0/mb_s_axi] [get_bd_intf_pins intx/M01_AXI]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins gpio/s_axi] [get_bd_intf_pins intx/M02_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins intx/M03_AXI] [get_bd_intf_pins sdram/s_axi_00]
  connect_bd_intf_net -intf_net pcie [get_bd_intf_ports pcie] [get_bd_intf_pins pcie_system/serial]
  connect_bd_intf_net -intf_net pcie_refclk [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins pcie_system/pcie_refclk]
  connect_bd_intf_net -intf_net pcie_system_m_axi [get_bd_intf_pins bar0/pcie_m_axi] [get_bd_intf_pins pcie_system/m_axi]
  connect_bd_intf_net -intf_net system_clk [get_bd_intf_ports system_clk] [get_bd_intf_pins clk_gen/system_clk]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins bar0/arst_n] [get_bd_pins clk_gen/arst_n] [get_bd_pins gpio/arst_n] [get_bd_pins intx/arst_n] [get_bd_pins mb_system/arst_n] [get_bd_pins pcie_system/arst_n] [get_bd_pins sdram/arst_n]
  connect_bd_net -net ctrl_clk [get_bd_pins clk_gen/ctrl_clk] [get_bd_pins mb_system/mb_clk] [get_bd_pins sdram/ctrl_clk]
  connect_bd_net -net data_clk [get_bd_pins bar0/clk] [get_bd_pins clk_gen/data_clk] [get_bd_pins gpio/clk] [get_bd_pins intx/clk] [get_bd_pins mb_system/m_axi_clk] [get_bd_pins pcie_system/axi_clk] [get_bd_pins sdram/data_clk]
  connect_bd_net -net hbm_cattrip [get_bd_ports hbm_cattrip] [get_bd_pins sdram/hbm_cattrip]
  connect_bd_net -net pcie_perst_n [get_bd_ports pcie_perst_n] [get_bd_pins clk_gen/pcie_perst_n] [get_bd_pins pcie_system/pcie_perst_n]
  connect_bd_net -net pcie_system_axi_clk_snoop [get_bd_ports pcie_axi_clk_snoop] [get_bd_pins pcie_system/axi_clk_snoop]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/dlmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0xA0050000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/fw_in/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0xA0060000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/fw_out/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x000100000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs sdram/hbm/SAXI_00/HBM_MEM00] -force
  assign_bd_address -offset 0x000110000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs sdram/hbm/SAXI_01/HBM_MEM01] -force
  assign_bd_address -offset 0x000120000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs sdram/hbm/SAXI_02/HBM_MEM02] -force
  assign_bd_address -offset 0x000130000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs sdram/hbm/SAXI_03/HBM_MEM03] -force
  assign_bd_address -offset 0x41200000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/intc/S_AXI/Reg] -force
  assign_bd_address -offset 0xA0040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/intc/s_axi/reg0] -force
  assign_bd_address -offset 0xA0000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs gpio/led/S_AXI/Reg] -force
  assign_bd_address -offset 0xA0080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs bar0/mb_bramc/S_AXI/Mem0] -force
  assign_bd_address -offset 0x41400000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/mdm/S_AXI/Reg] -force
  assign_bd_address -offset 0x0001000000000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/pcie/S_AXI_B/BAR0] -force
  assign_bd_address -offset 0xA4000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/remapper/s_axil/reg0] -force
  assign_bd_address -offset 0xA0030000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs gpio/system_management_wiz/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x41600000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/timer/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces mb_system/mb/Instruction] [get_bd_addr_segs mb_system/ilmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0xA0080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces pcie_system/pcie/M_AXI_B] [get_bd_addr_segs bar0/pcie_bramc/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces pcie_system/remapper/m_axil] [get_bd_addr_segs pcie_system/pcie/S_AXI_LITE/CTL0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


