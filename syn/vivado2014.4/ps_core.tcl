
################################################################
# This is a generated script based on design: ps_core
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ps_core_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1


# CHANGE DESIGN NAME HERE
set design_name ps_core

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set m_axi4l_peri00 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi4l_peri00 ]
  set_property -dict [ list CONFIG.ADDR_WIDTH {32} CONFIG.CLK_DOMAIN {ps_core_processing_system7_0_0_FCLK_CLK0} CONFIG.DATA_WIDTH {32} CONFIG.NUM_READ_OUTSTANDING {8} CONFIG.NUM_WRITE_OUTSTANDING {8} CONFIG.PROTOCOL {AXI4LITE}  ] $m_axi4l_peri00
  set m_axi4l_peri01 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi4l_peri01 ]
  set_property -dict [ list CONFIG.ADDR_WIDTH {32} CONFIG.DATA_WIDTH {32} CONFIG.NUM_READ_OUTSTANDING {2} CONFIG.NUM_WRITE_OUTSTANDING {2} CONFIG.PROTOCOL {AXI4}  ] $m_axi4l_peri01
  set s_axi4_mem00 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi4_mem00 ]
  set_property -dict [ list CONFIG.ADDR_WIDTH {32} CONFIG.ARUSER_WIDTH {0} CONFIG.AWUSER_WIDTH {0} CONFIG.BUSER_WIDTH {0} CONFIG.CLK_DOMAIN {ps_core_processing_system7_0_0_FCLK_CLK1} CONFIG.DATA_WIDTH {32} CONFIG.FREQ_HZ {175000000} CONFIG.ID_WIDTH {6} CONFIG.MAX_BURST_LENGTH {256} CONFIG.NUM_READ_OUTSTANDING {1} CONFIG.NUM_WRITE_OUTSTANDING {1} CONFIG.PHASE {0.000} CONFIG.PROTOCOL {AXI4} CONFIG.READ_WRITE_MODE {READ_WRITE} CONFIG.RUSER_WIDTH {0} CONFIG.SUPPORTS_NARROW_BURST {1} CONFIG.WUSER_WIDTH {0}  ] $s_axi4_mem00

  # Create ports
  set mem_aclk [ create_bd_port -dir O -type clk mem_aclk ]
  set mem_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst mem_aresetn ]
  set peri_aclk [ create_bd_port -dir O -type clk peri_aclk ]
  set peri_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst peri_aresetn ]
  set video_clk [ create_bd_port -dir O -type clk video_clk ]
  set video_clk_x5 [ create_bd_port -dir O -type clk video_clk_x5 ]
  set video_reset [ create_bd_port -dir O -from 0 -to 0 -type rst video_reset ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.NUM_MI {2}  ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list CONFIG.NUM_MI {1}  ] $axi_interconnect_1

  # Create instance: axi_protocol_converter_0, and set properties
  set axi_protocol_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_0 ]
  set_property -dict [ list CONFIG.MI_PROTOCOL {AXI4LITE}  ] $axi_protocol_converter_0

  # Create instance: proc_sys_reset_mem, and set properties
  set proc_sys_reset_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_mem ]

  # Create instance: proc_sys_reset_peri, and set properties
  set proc_sys_reset_peri [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_peri ]

  # Create instance: proc_sys_reset_video, and set properties
  set proc_sys_reset_video [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_video ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_EN_CLK3_PORT {1} CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {25.000000} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {125.000000} CONFIG.PCW_IMPORT_BOARD_PRESET {ZYBO_zynq_def.xml} CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {32} CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_USE_S_AXI_HP0 {1}  ] $processing_system7_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins axi_protocol_converter_0/M_AXI]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_ports s_axi4_mem00] [get_bd_intf_pins axi_interconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_ports m_axi4l_peri00] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_ports m_axi4l_peri01] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_protocol_converter_0/S_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net proc_sys_reset_mem_interconnect_aresetn [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins proc_sys_reset_mem/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_mem_peripheral_aresetn [get_bd_ports mem_aresetn] [get_bd_pins proc_sys_reset_mem/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_peri_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_protocol_converter_0/aresetn] [get_bd_pins proc_sys_reset_peri/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_peri_peripheral_aresetn [get_bd_ports peri_aresetn] [get_bd_pins proc_sys_reset_peri/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_video_peripheral_reset [get_bd_ports video_reset] [get_bd_pins proc_sys_reset_video/peripheral_reset]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_ports peri_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_protocol_converter_0/aclk] [get_bd_pins proc_sys_reset_peri/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_ports mem_aclk] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins proc_sys_reset_mem/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_ports video_clk] [get_bd_pins proc_sys_reset_video/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_CLK3 [get_bd_ports video_clk_x5] [get_bd_pins processing_system7_0/FCLK_CLK3]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_mem/ext_reset_in] [get_bd_pins proc_sys_reset_peri/ext_reset_in] [get_bd_pins proc_sys_reset_video/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs m_axi4l_peri00/Reg] SEG_m_axi4l_peri00_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs m_axi4l_peri01/Reg] SEG_m_axi4l_peri01_Reg
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces s_axi4_mem00] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


