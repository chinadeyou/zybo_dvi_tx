

`timescale 1n/1p
`default_nettype none


module vdma_axi4_to_axi4s
		#(
			parameter	CORE_ID          = 32'habcd_0000,
			parameter	CORE_VERSION     = 32'h0000_0000,
			
			parameter	AXI4_ID_WIDTH    = 6,
			parameter	AXI4_ADDR_WIDTH  = 32,
			parameter	AXI4_LEN_WIDTH   = 8,
			parameter	AXI4_QOS_WIDTH   = 4,
			parameter	AXI4S_USER_WIDTH = 1,
			parameter	AXI4S_DATA_WIDTH = 24,
			parameter	STRIDE_WIDTH     = 12,
			parameter	INDEX_WIDTH      = 8,
			parameter	H_WIDTH          = 12,
			parameter	V_WIDTH          = 12,
			
			parameter	WB_ADR_WIDTH     = 8,
			parameter	WB_DAT_WIDTH     = 32,
			parameter	WB_SEL_WIDTH     = (WB_DAT_WIDTH / 8),
			parameter	INIT_CTL_CONTROL  = 2'b00,
			parameter	INIT_PARAM_ADDR   = 32'h0000_0000,
			parameter	INIT_PARAM_STRIDE = 1024,
			parameter	INIT_PARAM_WIDTH  = 640,
			parameter	INIT_PARAM_HEIGHT = 480,
			parameter	INIT_PARAM_ARLEN  = 7
		)
		(
			// clk/reset
			input	wire							aresetn,
			input	wire							aclk,
			
			// master AXI4 (read)
			output	wire	[AXI4_ID_WIDTH-1:0]		m_axi4_arid,
			output	wire	[AXI4_ADDR_WIDTH-1:0]	m_axi4_araddr,
			output	wire	[1:0]					m_axi4_arburst,
			output	wire	[3:0]					m_axi4_arcache,
			output	wire	[AXI4_LEN_WIDTH-1:0]	m_axi4_arlen,
			output	wire	[0:0]					m_axi4_arlock,
			output	wire	[2:0]					m_axi4_arprot,
			output	wire	[AXI4_QOS_WIDTH-1:0]	m_axi4_arqos,
			output	wire	[3:0]					m_axi4_arregion,
			output	wire	[2:0]					m_axi4_arsize,
			output	wire							m_axi4_arvalid,
			input	wire							m_axi4_arready,
			input	wire	[AXI4_ID_WIDTH-1:0]		m_axi4_rid,
			input	wire	[1:0]					m_axi4_rresp,
			input	wire	[31:0]					m_axi4_rdata,
			input	wire							m_axi4_rlast,
			input	wire							m_axi4_rvalid,
			output	wire							m_axi4_rready,
			
			// master AXI4-Stream (output)
			output	wire	[AXI4S_USER_WIDTH-1:0]	m_axi4s_tuser,
			output	wire							m_axi4s_tlast,
			output	wire	[AXI4S_DATA_WIDTH-1:0]	m_axi4s_tdata,
			output	wire							m_axi4s_tvalid,
			input	wire							m_axi4s_tready,
			
			// WISHBONE (register access)
			input	wire							s_wb_rst_i,
			input	wire							s_wb_clk_i,
			input	wire	[WB_ADR_WIDTH-1:0]		s_wb_adr_i,
			output	wire	[WB_DAT_WIDTH-1:0]		s_wb_dat_o,
			input	wire	[WB_DAT_WIDTH-1:0]		s_wb_dat_i,
			input	wire							s_wb_we_i,
			input	wire	[WB_SEL_WIDTH-1:0]		s_wb_sel_i,
			input	wire							s_wb_stb_i,
			output	wire							s_wb_ack_o
		);
	
	
	
	// ---------------------------------
	//  Register
	// ---------------------------------
	
	localparam	REGOFFSET_ID             = 32'h0000_0000;
	localparam	REGOFFSET_VERSION        = 32'h0000_0004;
	
	localparam	REGOFFSET_CTL_CONTROL    = 32'h0000_0010;
	localparam	REGOFFSET_CTL_STATUS     = 32'h0000_0018;
	localparam	REGOFFSET_CTL_INDEX      = 32'h0000_001c;
	
	localparam	REGOFFSET_PARAM_ADDR     = 32'h0000_0020;
	localparam	REGOFFSET_PARAM_STRIDE   = 32'h0000_0024;
	localparam	REGOFFSET_PARAM_WIDTH    = 32'h0000_0028;
	localparam	REGOFFSET_PARAM_HEIGHT   = 32'h0000_002c;
	localparam	REGOFFSET_PARAM_ARLEN    = 32'h0000_0030;
	
	localparam	REGOFFSET_MONITOR_ADDR   = 32'h0000_0040;
	localparam	REGOFFSET_MONITOR_STRIDE = 32'h0000_0044;
	localparam	REGOFFSET_MONITOR_WIDTH  = 32'h0000_0048;
	localparam	REGOFFSET_MONITOR_HEIGHT = 32'h0000_004c;
	localparam	REGOFFSET_MONITOR_ARLEN  = 32'h0000_0050;
	
	reg		[1:0]					reg_ctl_control;
	wire	[0:0]					sig_ctl_status;
	wire	[INDEX_WIDTH-1:0]		sig_ctl_index;
	
	reg		[AXI4_ADDR_WIDTH-1:0]	reg_param_addr;
	reg		[STRIDE_WIDTH-1:0]		reg_param_stride;
	reg		[H_WIDTH-1:0]			reg_param_width;
	reg		[V_WIDTH-1:0]			reg_param_height;
	reg		[AXI4_LEN_WIDTH-1:0]	reg_param_arlen;
	
	wire	[AXI4_ADDR_WIDTH-1:0]	sig_monitor_addr;
	wire	[STRIDE_WIDTH-1:0]		sig_monitor_stride;
	wire	[H_WIDTH-1:0]			sig_monitor_width;
	wire	[V_WIDTH-1:0]			sig_monitor_height;
	wire	[AXI4_LEN_WIDTH-1:0]	sig_monitor_arlen;
	
	reg								reg_prev_index;
	
	always @(posedge s_wb_clk_i ) begin
		if ( s_wb_rst_i ) begin
			reg_ctl_control  <= INIT_CTL_CONTROL;
			reg_param_addr   <= INIT_PARAM_ADDR;
			reg_param_stride <= INIT_PARAM_STRIDE;
			reg_param_width  <= INIT_PARAM_WIDTH;
			reg_param_height <= INIT_PARAM_HEIGHT;
			reg_param_arlen  <= INIT_PARAM_ARLEN;
			reg_prev_index   <= 1'b0;
		end
		else if ( s_wb_stb_i && s_wb_we_i) begin
			case ( s_wb_adr_i )
			REGOFFSET_CTL_CONTROL:	reg_ctl_control  <= s_wb_dat_i;
			REGOFFSET_PARAM_ADDR:	reg_param_addr   <= s_wb_dat_i;
			REGOFFSET_PARAM_STRIDE:	reg_param_stride <= s_wb_dat_i;
			REGOFFSET_PARAM_WIDTH:	reg_param_width  <= s_wb_dat_i;
			REGOFFSET_PARAM_HEIGHT:	reg_param_height <= s_wb_dat_i;
			REGOFFSET_PARAM_ARLEN:	reg_param_arlen  <= s_wb_dat_i;
			endcase
		end
		
		// update flag auto clear
		reg_prev_index <= sig_ctl_index[0];
		if ( reg_prev_index != sig_ctl_index[0] ) begin
			reg_ctl_control[1] <= 1'b0;
		end
	end
	
	assign s_wb_dat_o = (s_wb_adr_i == REGOFFSET_ID)             ? CORE_ID            :
	                    (s_wb_adr_i == REGOFFSET_VERSION)        ? CORE_VERSION       :
	                    (s_wb_adr_i == REGOFFSET_CTL_CONTROL)    ? reg_ctl_control    :
	                    (s_wb_adr_i == REGOFFSET_CTL_STATUS)     ? sig_ctl_status     :
	                    (s_wb_adr_i == REGOFFSET_CTL_INDEX)      ? sig_ctl_index      :
	                    (s_wb_adr_i == REGOFFSET_PARAM_ADDR)     ? reg_param_addr     :
	                    (s_wb_adr_i == REGOFFSET_PARAM_STRIDE)   ? reg_param_stride   :
	                    (s_wb_adr_i == REGOFFSET_PARAM_WIDTH)    ? reg_param_width    :
	                    (s_wb_adr_i == REGOFFSET_PARAM_HEIGHT)   ? reg_param_height   :
	                    (s_wb_adr_i == REGOFFSET_PARAM_ARLEN)    ? reg_param_arlen    :
	                    (s_wb_adr_i == REGOFFSET_MONITOR_ADDR)   ? sig_monitor_addr   :
	                    (s_wb_adr_i == REGOFFSET_MONITOR_STRIDE) ? sig_monitor_stride :
	                    (s_wb_adr_i == REGOFFSET_MONITOR_WIDTH)  ? sig_monitor_width  :
	                    (s_wb_adr_i == REGOFFSET_MONITOR_HEIGHT) ? sig_monitor_height :
	                    (s_wb_adr_i == REGOFFSET_MONITOR_ARLEN)  ? sig_monitor_arlen  :
	                    32'h0000_0000;
	
	assign s_wb_ack_o = s_wb_stb_i;
	
	
	
	// ---------------------------------
	//  Core
	// ---------------------------------
	
	vdma_axi4_to_axi4s_core
			#(
				.AXI4_ID_WIDTH		(AXI4_ID_WIDTH),
				.AXI4_ADDR_WIDTH	(AXI4_ADDR_WIDTH),
				.AXI4_LEN_WIDTH		(AXI4_LEN_WIDTH),
				.AXI4_QOS_WIDTH		(AXI4_QOS_WIDTH),
				.AXI4S_USER_WIDTH	(AXI4S_USER_WIDTH),
				.AXI4S_DATA_WIDTH	(AXI4S_DATA_WIDTH),
				.STRIDE_WIDTH		(STRIDE_WIDTH),
				.INDEX_WIDTH		(INDEX_WIDTH),
				.H_WIDTH			(H_WIDTH),
				.V_WIDTH			(V_WIDTH)
			)
		i_vdma_axi4_to_axi4s_core
			(
				.aresetn			(aresetn),
				.aclk				(aclk),
				
				.ctl_enable			(reg_ctl_control[0]),
				.ctl_update			(reg_ctl_control[1]),
				.ctl_busy			(sig_ctl_status[0]),
				.ctl_index			(sig_ctl_index),
				
				.param_addr			(reg_param_addr),
				.param_stride		(reg_param_stride),
				.param_width		(reg_param_width),
				.param_height		(reg_param_height),
				.param_arlen		(reg_param_arlen),
				
				.monitor_addr		(sig_monitor_addr),
				.monitor_stride		(sig_monitor_stride),
				.monitor_width		(sig_monitor_width),
				.monitor_height		(sig_monitor_height),
				.monitor_arlen		(sig_monitor_arlen),
				
				.m_axi4_arid		(m_axi4_arid),
				.m_axi4_araddr		(m_axi4_araddr),
				.m_axi4_arburst		(m_axi4_arburst),
				.m_axi4_arcache		(m_axi4_arcache),
				.m_axi4_arlen		(m_axi4_arlen),
				.m_axi4_arlock		(m_axi4_arlock),
				.m_axi4_arprot		(m_axi4_arprot),
				.m_axi4_arqos		(m_axi4_arqos),
				.m_axi4_arregion	(m_axi4_arregion),
				.m_axi4_arsize		(m_axi4_arsize),
				.m_axi4_arvalid		(m_axi4_arvalid),
				.m_axi4_arready		(m_axi4_arready),
				.m_axi4_rid			(m_axi4_rid),
				.m_axi4_rresp		(m_axi4_rresp),
				.m_axi4_rdata		(m_axi4_rdata),
				.m_axi4_rlast		(m_axi4_rlast),
				.m_axi4_rvalid		(m_axi4_rvalid),
				.m_axi4_rready		(m_axi4_rready),
				
				.m_axi4s_tuser		(m_axi4s_tuser),
				.m_axi4s_tlast		(m_axi4s_tlast),
				.m_axi4s_tdata		(m_axi4s_tdata),
				.m_axi4s_tvalid		(m_axi4s_tvalid),
				.m_axi4s_tready		(m_axi4s_tready)
		);
		
endmodule


`default_nettype wire


// end of file
