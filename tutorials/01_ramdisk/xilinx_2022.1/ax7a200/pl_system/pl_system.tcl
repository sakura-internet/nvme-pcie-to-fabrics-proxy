
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
# msi_intc

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a200tfbg484-2
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
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_firewall:1.2\
xilinx.com:ip:axi_pcie:2.9\
xilinx.com:ip:mig_7series:4.2\
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
msi_intc\
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
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_pl_system_mig_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {﻿<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  }
   puts $mig_prj_file {<!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {  <ModuleName>pl_system_mig_7series_0_0</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Enabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7a200t-fbg484/-2</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>No Buffer</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>No Buffer</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE LOW</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>0</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41K256M16XX-125</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>2500</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>200</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>800</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>32</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Normal</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName/>}
   puts $mig_prj_file {    <RowAddress>15</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>1073741824</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AA4" SLEW="" VCCAUX_IO="" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="Y1" SLEW="" VCCAUX_IO="" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="W2" SLEW="" VCCAUX_IO="" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="Y2" SLEW="" VCCAUX_IO="" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="U1" SLEW="" VCCAUX_IO="" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="V3" SLEW="" VCCAUX_IO="" name="ddr3_addr[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AB2" SLEW="" VCCAUX_IO="" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AA5" SLEW="" VCCAUX_IO="" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AB5" SLEW="" VCCAUX_IO="" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AB1" SLEW="" VCCAUX_IO="" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="U3" SLEW="" VCCAUX_IO="" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="W1" SLEW="" VCCAUX_IO="" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="T1" SLEW="" VCCAUX_IO="" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="V2" SLEW="" VCCAUX_IO="" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="U2" SLEW="" VCCAUX_IO="" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AA3" SLEW="" VCCAUX_IO="" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="Y3" SLEW="" VCCAUX_IO="" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="Y4" SLEW="" VCCAUX_IO="" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="W4" SLEW="" VCCAUX_IO="" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="R2" SLEW="" VCCAUX_IO="" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="R3" SLEW="" VCCAUX_IO="" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="T5" SLEW="" VCCAUX_IO="" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AB3" SLEW="" VCCAUX_IO="" name="ddr3_cs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="D2" SLEW="" VCCAUX_IO="" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="G2" SLEW="" VCCAUX_IO="" name="ddr3_dm[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="M2" SLEW="" VCCAUX_IO="" name="ddr3_dm[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="M5" SLEW="" VCCAUX_IO="" name="ddr3_dm[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="C2" SLEW="" VCCAUX_IO="" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="H2" SLEW="" VCCAUX_IO="" name="ddr3_dq[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="H5" SLEW="" VCCAUX_IO="" name="ddr3_dq[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="J1" SLEW="" VCCAUX_IO="" name="ddr3_dq[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="J5" SLEW="" VCCAUX_IO="" name="ddr3_dq[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="K1" SLEW="" VCCAUX_IO="" name="ddr3_dq[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="H4" SLEW="" VCCAUX_IO="" name="ddr3_dq[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="L4" SLEW="" VCCAUX_IO="" name="ddr3_dq[16]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="M3" SLEW="" VCCAUX_IO="" name="ddr3_dq[17]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="L3" SLEW="" VCCAUX_IO="" name="ddr3_dq[18]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="J6" SLEW="" VCCAUX_IO="" name="ddr3_dq[19]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="G1" SLEW="" VCCAUX_IO="" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="K3" SLEW="" VCCAUX_IO="" name="ddr3_dq[20]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="K6" SLEW="" VCCAUX_IO="" name="ddr3_dq[21]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="J4" SLEW="" VCCAUX_IO="" name="ddr3_dq[22]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="L5" SLEW="" VCCAUX_IO="" name="ddr3_dq[23]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="P1" SLEW="" VCCAUX_IO="" name="ddr3_dq[24]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="N4" SLEW="" VCCAUX_IO="" name="ddr3_dq[25]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="R1" SLEW="" VCCAUX_IO="" name="ddr3_dq[26]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="N2" SLEW="" VCCAUX_IO="" name="ddr3_dq[27]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="M6" SLEW="" VCCAUX_IO="" name="ddr3_dq[28]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="N5" SLEW="" VCCAUX_IO="" name="ddr3_dq[29]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="A1" SLEW="" VCCAUX_IO="" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="P6" SLEW="" VCCAUX_IO="" name="ddr3_dq[30]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="P2" SLEW="" VCCAUX_IO="" name="ddr3_dq[31]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="F3" SLEW="" VCCAUX_IO="" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="B2" SLEW="" VCCAUX_IO="" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="F1" SLEW="" VCCAUX_IO="" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="B1" SLEW="" VCCAUX_IO="" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="E2" SLEW="" VCCAUX_IO="" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="H3" SLEW="" VCCAUX_IO="" name="ddr3_dq[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="G3" SLEW="" VCCAUX_IO="" name="ddr3_dq[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="D1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="J2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="L1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="P4" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="E1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="K2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="M1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="P5" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="U5" SLEW="" VCCAUX_IO="" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="V4" SLEW="" VCCAUX_IO="" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="W6" SLEW="" VCCAUX_IO="" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="" PADName="AA1" SLEW="" VCCAUX_IO="" name="ddr3_we_n"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5" tfaw="40" tras="35" trcd="13.75" trefi="7.8" trfc="260" trp="13.75" trrd="7.5" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">6</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Enable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/4</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">5</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>30</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>256</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>1</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_pl_system_mig_0()



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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk mig_clk_ref
  create_bd_pin -dir I -type clk mig_clk_sys
  create_bd_pin -dir I -type clk s_axi_clk

  # Create instance: const_high, and set properties
  set const_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_high ]

  # Create instance: intx, and set properties
  set intx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.S00_HAS_REGSLICE {4} \
 ] $intx

  # Create instance: mig, and set properties
  set mig [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_pl_system_mig_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_a.prj} \
 ] $mig

  # Create instance: rstgen, and set properties
  set rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rstgen ]

  # Create interface connections
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intx/M00_AXI] [get_bd_intf_pins mig/S_AXI]
  connect_bd_intf_net -intf_net mig_DDR3 [get_bd_intf_pins DDR3] [get_bd_intf_pins mig/DDR3]
  connect_bd_intf_net -intf_net s_axi [get_bd_intf_pins s_axi] [get_bd_intf_pins intx/S00_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx/ARESETN] [get_bd_pins intx/S00_ARESETN] [get_bd_pins mig/sys_rst]
  connect_bd_net -net const_high_dout [get_bd_pins const_high/dout] [get_bd_pins rstgen/aux_reset_in]
  connect_bd_net -net mig_clk_ref [get_bd_pins mig_clk_ref] [get_bd_pins mig/clk_ref_i]
  connect_bd_net -net mig_clk_sys [get_bd_pins mig_clk_sys] [get_bd_pins mig/sys_clk_i]
  connect_bd_net -net mig_mmcm_locked [get_bd_pins mig/mmcm_locked] [get_bd_pins rstgen/dcm_locked]
  connect_bd_net -net mig_ui_clk [get_bd_pins intx/M00_ACLK] [get_bd_pins mig/ui_clk] [get_bd_pins rstgen/slowest_sync_clk]
  connect_bd_net -net mig_ui_clk_sync_rst [get_bd_pins mig/ui_clk_sync_rst] [get_bd_pins rstgen/ext_reset_in]
  connect_bd_net -net rstgen_peripheral_aresetn [get_bd_pins intx/M00_ARESETN] [get_bd_pins mig/aresetn] [get_bd_pins rstgen/peripheral_aresetn]
  connect_bd_net -net s_axi_clk [get_bd_pins s_axi_clk] [get_bd_pins intx/ACLK] [get_bd_pins intx/S00_ACLK]

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

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir O -type clk axi_clk_snoop
  create_bd_pin -dir I -type rst pcie_perst_n
  create_bd_pin -dir I -type clk pcie_refclk
  create_bd_pin -dir I -type clk s_axi_clk

  # Create instance: fw_in, and set properties
  set fw_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 fw_in ]

  # Create instance: fw_out, and set properties
  set fw_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 fw_out ]

  # Create instance: intc, and set properties
  set block_name msi_intc
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
 ] $intx_out

  # Create instance: pcie, and set properties
  set pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.9 pcie ]
  set_property -dict [ list \
   CONFIG.AXIBAR2PCIEBAR_0 {0x0000000000000000} \
   CONFIG.AXIBAR_AS_0 {true} \
   CONFIG.BAR0_SIZE {128} \
   CONFIG.BAR_64BIT {true} \
   CONFIG.BASE_CLASS_MENU {Mass_storage_controller} \
   CONFIG.CLASS_CODE {0x010802} \
   CONFIG.DEVICE_ID {0x7022} \
   CONFIG.ENABLE_CLASS_CODE {true} \
   CONFIG.MAX_LINK_SPEED {5.0_GT/s} \
   CONFIG.M_AXI_DATA_WIDTH {64} \
   CONFIG.NO_OF_LANES {X2} \
   CONFIG.NUM_MSI_REQ {4} \
   CONFIG.PCIEBAR2AXIBAR_0 {0xA0080000} \
   CONFIG.SUB_CLASS_INTERFACE_MENU {Other_mass_storage_controller} \
   CONFIG.S_AXI_DATA_WIDTH {64} \
   CONFIG.S_AXI_SUPPORTS_NARROW_BURST {true} \
 ] $pcie

  # Create instance: rstgen, and set properties
  set rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rstgen ]

  # Create interface connections
  connect_bd_intf_net -intf_net fw_in_M_AXI [get_bd_intf_pins fw_in/M_AXI] [get_bd_intf_pins intx_in/S00_AXI]
  connect_bd_intf_net -intf_net fw_out_M_AXI [get_bd_intf_pins m_axi] [get_bd_intf_pins fw_out/M_AXI]
  connect_bd_intf_net -intf_net intx_fw_M00_AXI [get_bd_intf_pins fw_in/S_AXI] [get_bd_intf_pins intx_fw/M00_AXI]
  connect_bd_intf_net -intf_net intx_fw_M01_AXI [get_bd_intf_pins fw_in/S_AXI_CTL] [get_bd_intf_pins intx_fw/M01_AXI]
  connect_bd_intf_net -intf_net intx_fw_M02_AXI [get_bd_intf_pins fw_out/S_AXI_CTL] [get_bd_intf_pins intx_fw/M02_AXI]
  connect_bd_intf_net -intf_net intx_in_M00_AXI [get_bd_intf_pins intx_in/M00_AXI] [get_bd_intf_pins pcie/S_AXI]
  connect_bd_intf_net -intf_net intx_in_M01_AXI [get_bd_intf_pins intx_in/M01_AXI] [get_bd_intf_pins pcie/S_AXI_CTL]
  connect_bd_intf_net -intf_net intx_in_M02_AXI [get_bd_intf_pins intc/s_axi] [get_bd_intf_pins intx_in/M02_AXI]
  connect_bd_intf_net -intf_net intx_out_M00_AXI [get_bd_intf_pins fw_out/S_AXI] [get_bd_intf_pins intx_out/M00_AXI]
  connect_bd_intf_net -intf_net pcie_M_AXI [get_bd_intf_pins intx_out/S00_AXI] [get_bd_intf_pins pcie/M_AXI]
  connect_bd_intf_net -intf_net pcie_pcie_7x_mgt [get_bd_intf_pins pcie_7x_mgt] [get_bd_intf_pins pcie/pcie_7x_mgt]
  connect_bd_intf_net -intf_net s_axi [get_bd_intf_pins s_axi] [get_bd_intf_pins intx_fw/S00_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins fw_in/aresetn] [get_bd_pins fw_out/aresetn] [get_bd_pins intx_fw/ARESETN] [get_bd_pins intx_fw/M00_ARESETN] [get_bd_pins intx_fw/M01_ARESETN] [get_bd_pins intx_fw/M02_ARESETN] [get_bd_pins intx_fw/S00_ARESETN] [get_bd_pins intx_in/S00_ARESETN] [get_bd_pins intx_out/M00_ARESETN] [get_bd_pins rstgen/ext_reset_in]
  connect_bd_net -net intc_msi_request [get_bd_pins intc/msi_request] [get_bd_pins pcie/INTX_MSI_Request]
  connect_bd_net -net intc_msi_vector_num [get_bd_pins intc/msi_vector_num] [get_bd_pins pcie/MSI_Vector_Num]
  connect_bd_net -net pcie_INTX_MSI_Grant [get_bd_pins intc/msi_grant] [get_bd_pins pcie/INTX_MSI_Grant]
  connect_bd_net -net pcie_axi_aclk_out [get_bd_pins axi_clk_snoop] [get_bd_pins intc/aclk] [get_bd_pins intx_in/ACLK] [get_bd_pins intx_in/M00_ACLK] [get_bd_pins intx_in/M02_ACLK] [get_bd_pins intx_out/ACLK] [get_bd_pins intx_out/S00_ACLK] [get_bd_pins pcie/axi_aclk_out] [get_bd_pins rstgen/slowest_sync_clk]
  connect_bd_net -net pcie_axi_ctl_aclk_out [get_bd_pins intx_in/M01_ACLK] [get_bd_pins pcie/axi_ctl_aclk_out]
  connect_bd_net -net pcie_mmcm_lock [get_bd_pins pcie/mmcm_lock] [get_bd_pins rstgen/dcm_locked]
  connect_bd_net -net pcie_perst_n [get_bd_pins pcie_perst_n] [get_bd_pins rstgen/aux_reset_in]
  connect_bd_net -net pcie_refclk [get_bd_pins pcie_refclk] [get_bd_pins pcie/REFCLK]
  connect_bd_net -net rstgen_interconnect_aresetn [get_bd_pins intx_in/ARESETN] [get_bd_pins intx_in/M00_ARESETN] [get_bd_pins intx_in/M01_ARESETN] [get_bd_pins intx_out/ARESETN] [get_bd_pins intx_out/S00_ARESETN] [get_bd_pins pcie/axi_aresetn] [get_bd_pins rstgen/interconnect_aresetn]
  connect_bd_net -net rstgen_peripheral_aresetn [get_bd_pins intc/aresetn] [get_bd_pins intx_in/M02_ARESETN] [get_bd_pins rstgen/peripheral_aresetn]
  connect_bd_net -net s_axi_clk [get_bd_pins s_axi_clk] [get_bd_pins fw_in/aclk] [get_bd_pins fw_out/aclk] [get_bd_pins intx_fw/ACLK] [get_bd_pins intx_fw/M00_ACLK] [get_bd_pins intx_fw/M01_ACLK] [get_bd_pins intx_fw/M02_ACLK] [get_bd_pins intx_fw/S00_ACLK] [get_bd_pins intx_in/S00_ACLK] [get_bd_pins intx_out/M00_ACLK]

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
  create_bd_pin -dir I arst_n
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
   CONFIG.C_ADDR_SIZE {36} \
   CONFIG.C_ADDR_TAG_BITS {0} \
   CONFIG.C_AREA_OPTIMIZED {1} \
   CONFIG.C_CACHE_BYTE_SIZE {4096} \
   CONFIG.C_DCACHE_ADDR_TAG {0} \
   CONFIG.C_DCACHE_BYTE_SIZE {4096} \
   CONFIG.C_DCACHE_HIGHADDR {0x000000003fffffff} \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_ICACHE_HIGHADDR {0x000000003fffffff} \
   CONFIG.C_I_LMB {1} \
   CONFIG.C_MMU_DTLB_SIZE {2} \
   CONFIG.C_MMU_ITLB_SIZE {1} \
   CONFIG.C_MMU_ZONES {2} \
   CONFIG.C_M_AXI_DC_ADDR_WIDTH {36} \
   CONFIG.C_M_AXI_DP_ADDR_WIDTH {36} \
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
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intc/s_axi] [get_bd_intf_pins intx/M00_AXI]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins intx/M01_AXI] [get_bd_intf_pins mdm/S_AXI]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins intx/M02_AXI] [get_bd_intf_pins timer/S_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins m_axi] [get_bd_intf_pins intx/M03_AXI]
  connect_bd_intf_net -intf_net mb_DLMB [get_bd_intf_pins dlmb_v10/LMB_M] [get_bd_intf_pins mb/DLMB]
  connect_bd_intf_net -intf_net mb_ILMB [get_bd_intf_pins ilmb_v10/LMB_M] [get_bd_intf_pins mb/ILMB]
  connect_bd_intf_net -intf_net mb_M_AXI_DP [get_bd_intf_pins intx/S00_AXI] [get_bd_intf_pins mb/M_AXI_DP]
  connect_bd_intf_net -intf_net mdm_MBDEBUG_0 [get_bd_intf_pins mb/DEBUG] [get_bd_intf_pins mdm/MBDEBUG_0]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx/M03_ARESETN] [get_bd_pins rstgen/ext_reset_in]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins intc/intr] [get_bd_pins timer/interrupt]
  connect_bd_net -net const_high_dout [get_bd_pins const_high/dout] [get_bd_pins rstgen/aux_reset_in] [get_bd_pins rstgen/dcm_locked]
  connect_bd_net -net m_axi_clk [get_bd_pins m_axi_clk] [get_bd_pins intx/M03_ACLK]
  connect_bd_net -net mb_clk [get_bd_pins mb_clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk] [get_bd_pins intc/processor_clk] [get_bd_pins intc/s_axi_aclk] [get_bd_pins intx/ACLK] [get_bd_pins intx/M00_ACLK] [get_bd_pins intx/M01_ACLK] [get_bd_pins intx/M02_ACLK] [get_bd_pins intx/S00_ACLK] [get_bd_pins mb/Clk] [get_bd_pins mdm/S_AXI_ACLK] [get_bd_pins rstgen/slowest_sync_clk] [get_bd_pins timer/s_axi_aclk]
  connect_bd_net -net mdm_Debug_SYS_Rst [get_bd_pins mdm/Debug_SYS_Rst] [get_bd_pins rstgen/mb_debug_sys_rst]
  connect_bd_net -net rstgen_bus_struct_reset [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst] [get_bd_pins rstgen/bus_struct_reset]
  connect_bd_net -net rstgen_interconnect_aresetn [get_bd_pins intx/ARESETN] [get_bd_pins rstgen/interconnect_aresetn]
  connect_bd_net -net rstgen_mb_reset [get_bd_pins intc/processor_rst] [get_bd_pins mb/Reset] [get_bd_pins rstgen/mb_reset]
  connect_bd_net -net rstgen_peripheral_aresetn [get_bd_pins intc/s_axi_aresetn] [get_bd_pins intx/M00_ARESETN] [get_bd_pins intx/M01_ARESETN] [get_bd_pins intx/M02_ARESETN] [get_bd_pins intx/S00_ARESETN] [get_bd_pins mdm/S_AXI_ARESETN] [get_bd_pins rstgen/peripheral_aresetn] [get_bd_pins timer/s_axi_aresetn]

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
  create_bd_pin -dir I arst_n
  create_bd_pin -dir I -type clk clk

  # Create instance: intx_core, and set properties
  set intx_core [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx_core ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {1} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.S01_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $intx_core

  # Create interface connections
  connect_bd_intf_net -intf_net ctrl_m_axi [get_bd_intf_pins S00_AXI] [get_bd_intf_pins intx_core/S00_AXI]
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins intx_core/M00_AXI]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins intx_core/M01_AXI]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins intx_core/M02_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins intx_core/M03_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx_core/ARESETN] [get_bd_pins intx_core/M00_ARESETN] [get_bd_pins intx_core/M01_ARESETN] [get_bd_pins intx_core/M02_ARESETN] [get_bd_pins intx_core/M03_ARESETN] [get_bd_pins intx_core/S00_ARESETN]
  connect_bd_net -net clk_100 [get_bd_pins clk] [get_bd_pins intx_core/ACLK] [get_bd_pins intx_core/M00_ACLK] [get_bd_pins intx_core/M01_ACLK] [get_bd_pins intx_core/M02_ACLK] [get_bd_pins intx_core/M03_ACLK] [get_bd_pins intx_core/S00_ACLK]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_led

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type rst arst_n
  create_bd_pin -dir I -type clk clk

  # Create instance: intx, and set properties
  set intx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 intx ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.S00_HAS_REGSLICE {4} \
 ] $intx

  # Create instance: led, and set properties
  set led [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 led ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {4} \
 ] $led

  # Create interface connections
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intx/M00_AXI] [get_bd_intf_pins led/S_AXI]
  connect_bd_intf_net -intf_net led_GPIO [get_bd_intf_pins gpio_led] [get_bd_intf_pins led/GPIO]
  connect_bd_intf_net -intf_net s_axi [get_bd_intf_pins s_axi] [get_bd_intf_pins intx/S00_AXI]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_pins arst_n] [get_bd_pins intx/ARESETN] [get_bd_pins intx/M00_ARESETN] [get_bd_pins intx/S00_ARESETN] [get_bd_pins led/s_axi_aresetn]
  connect_bd_net -net clk [get_bd_pins clk] [get_bd_pins intx/ACLK] [get_bd_pins intx/M00_ACLK] [get_bd_pins intx/S00_ACLK] [get_bd_pins led/s_axi_aclk]

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

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 pcie_s_axi


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
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $mb_bramc

  # Create instance: pcie_bramc, and set properties
  set pcie_bramc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 pcie_bramc ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $pcie_bramc

  # Create interface connections
  connect_bd_intf_net -intf_net bramc_BRAM_PORTA [get_bd_intf_pins bram/BRAM_PORTA] [get_bd_intf_pins mb_bramc/BRAM_PORTA]
  connect_bd_intf_net -intf_net mb_s_axi [get_bd_intf_pins mb_s_axi] [get_bd_intf_pins mb_bramc/S_AXI]
  connect_bd_intf_net -intf_net pcie_bramc_BRAM_PORTA [get_bd_intf_pins bram/BRAM_PORTB] [get_bd_intf_pins pcie_bramc/BRAM_PORTA]
  connect_bd_intf_net -intf_net pcie_s_axi [get_bd_intf_pins pcie_s_axi] [get_bd_intf_pins pcie_bramc/S_AXI]

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
  set DDR3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3 ]

  set gpio_led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_led ]

  set pcie [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie ]


  # Create ports
  set arst_n [ create_bd_port -dir I arst_n ]
  set clk_100 [ create_bd_port -dir I -type clk -freq_hz 100000000 clk_100 ]
  set clk_200 [ create_bd_port -dir I -type clk -freq_hz 200000000 clk_200 ]
  set clk_400 [ create_bd_port -dir I -type clk -freq_hz 400000000 clk_400 ]
  set pcie_axi_clk_snoop [ create_bd_port -dir O -type clk pcie_axi_clk_snoop ]
  set pcie_perst_n [ create_bd_port -dir I -type rst pcie_perst_n ]
  set pcie_refclk [ create_bd_port -dir I -type clk pcie_refclk ]

  # Create instance: bar0
  create_hier_cell_bar0 [current_bd_instance .] bar0

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
  connect_bd_intf_net -intf_net gpio_gpio_led [get_bd_intf_ports gpio_led] [get_bd_intf_pins gpio/gpio_led]
  connect_bd_intf_net -intf_net intx_M00_AXI [get_bd_intf_pins intx/M00_AXI] [get_bd_intf_pins pcie_system/s_axi]
  connect_bd_intf_net -intf_net intx_M01_AXI [get_bd_intf_pins intx/M01_AXI] [get_bd_intf_pins sdram/s_axi]
  connect_bd_intf_net -intf_net intx_M02_AXI [get_bd_intf_pins bar0/mb_s_axi] [get_bd_intf_pins intx/M02_AXI]
  connect_bd_intf_net -intf_net intx_M03_AXI [get_bd_intf_pins gpio/s_axi] [get_bd_intf_pins intx/M03_AXI]
  connect_bd_intf_net -intf_net mb_system_m_axi [get_bd_intf_pins intx/S00_AXI] [get_bd_intf_pins mb_system/m_axi]
  connect_bd_intf_net -intf_net pcie_system_m_axi [get_bd_intf_pins bar0/pcie_s_axi] [get_bd_intf_pins pcie_system/m_axi]
  connect_bd_intf_net -intf_net pcie_system_pcie_7x_mgt_0 [get_bd_intf_ports pcie] [get_bd_intf_pins pcie_system/pcie_7x_mgt]
  connect_bd_intf_net -intf_net sdram_DDR3 [get_bd_intf_ports DDR3] [get_bd_intf_pins sdram/DDR3]

  # Create port connections
  connect_bd_net -net arst_n [get_bd_ports arst_n] [get_bd_pins bar0/arst_n] [get_bd_pins gpio/arst_n] [get_bd_pins intx/arst_n] [get_bd_pins mb_system/arst_n] [get_bd_pins pcie_system/arst_n] [get_bd_pins sdram/arst_n]
  connect_bd_net -net clk_100 [get_bd_ports clk_100] [get_bd_pins bar0/clk] [get_bd_pins gpio/clk] [get_bd_pins intx/clk] [get_bd_pins mb_system/m_axi_clk] [get_bd_pins pcie_system/s_axi_clk] [get_bd_pins sdram/s_axi_clk]
  connect_bd_net -net clk_200 [get_bd_ports clk_200] [get_bd_pins mb_system/mb_clk] [get_bd_pins sdram/mig_clk_sys]
  connect_bd_net -net clk_400 [get_bd_ports clk_400] [get_bd_pins sdram/mig_clk_ref]
  connect_bd_net -net pcie_perst_n [get_bd_ports pcie_perst_n] [get_bd_pins pcie_system/pcie_perst_n]
  connect_bd_net -net pcie_refclk [get_bd_ports pcie_refclk] [get_bd_pins pcie_system/pcie_refclk]
  connect_bd_net -net pcie_system_axi_clk_snoop [get_bd_ports pcie_axi_clk_snoop] [get_bd_pins pcie_system/axi_clk_snoop]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/dlmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0xA0050000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/fw_in/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0xA0060000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/fw_out/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x41200000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/intc/S_AXI/Reg] -force
  assign_bd_address -offset 0xA0040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/intc/s_axi/reg0] -force
  assign_bd_address -offset 0xA0000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs gpio/led/S_AXI/Reg] -force
  assign_bd_address -offset 0xA0080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs bar0/mb_bramc/S_AXI/Mem0] -force
  assign_bd_address -offset 0x41400000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/mdm/S_AXI/Reg] -force
  assign_bd_address -offset 0x000800000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs sdram/mig/memmap/memaddr] -force
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/pcie/S_AXI/BAR0] -force
  assign_bd_address -offset 0xA4000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs pcie_system/pcie/S_AXI_CTL/CTL0] -force
  assign_bd_address -offset 0x41600000 -range 0x00001000 -target_address_space [get_bd_addr_spaces mb_system/mb/Data] [get_bd_addr_segs mb_system/timer/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces mb_system/mb/Instruction] [get_bd_addr_segs mb_system/ilmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0xA0080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces pcie_system/pcie/M_AXI] [get_bd_addr_segs bar0/pcie_bramc/S_AXI/Mem0] -force


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


