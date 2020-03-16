
`timescale 1 ns / 1 ps

	module cmlk_imaging_ctrl_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
		output wire init_txn,
		output wire diff_en,
		input wire ext_trig_overflow,
		input wire fifo_overflow,
		input wire unexpected_data,
		input wire unexpected_tlast,
		output wire img_wr2ddr_en,

		output wire [31:0] alg_base_addr,
		output wire alg_load_addr,
		input wire alg_lost_read,

		input wire frame_2d_store,
		input wire frame_3d_store,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  s_axi_aclk,
		input wire  s_axi_aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready
	);
	
	// Instantiation of Axi Bus Interface S_AXI
	cmlk_imaging_ctrl_v1_0_S_AXI #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) cmlk_imaging_ctrl_v1_0_S_AXI_inst (
		.init_txn         (init_txn         ),
		.diff_en          (diff_en          ),
		.ext_trig_overflow(ext_trig_overflow),
		.fifo_overflow    (fifo_overflow    ),
		.unexpected_data  (unexpected_data  ),
		.unexpected_tlast (unexpected_tlast ),
		.img_wr2ddr_en    (img_wr2ddr_en    ),
		.alg_base_addr    (alg_base_addr    ),
		.alg_load_addr    (alg_load_addr    ),
		.alg_lost_read    (alg_lost_read    ),
		.frame_2d_store   (frame_2d_store   ),
		.frame_3d_store   (frame_3d_store   ),
		.S_AXI_ACLK       (s_axi_aclk       ),
		.S_AXI_ARESETN    (s_axi_aresetn    ),
		.S_AXI_AWADDR     (s_axi_awaddr     ),
		.S_AXI_AWPROT     (s_axi_awprot     ),
		.S_AXI_AWVALID    (s_axi_awvalid    ),
		.S_AXI_AWREADY    (s_axi_awready    ),
		.S_AXI_WDATA      (s_axi_wdata      ),
		.S_AXI_WSTRB      (s_axi_wstrb      ),
		.S_AXI_WVALID     (s_axi_wvalid     ),
		.S_AXI_WREADY     (s_axi_wready     ),
		.S_AXI_BRESP      (s_axi_bresp      ),
		.S_AXI_BVALID     (s_axi_bvalid     ),
		.S_AXI_BREADY     (s_axi_bready     ),
		.S_AXI_ARADDR     (s_axi_araddr     ),
		.S_AXI_ARPROT     (s_axi_arprot     ),
		.S_AXI_ARVALID    (s_axi_arvalid    ),
		.S_AXI_ARREADY    (s_axi_arready    ),
		.S_AXI_RDATA      (s_axi_rdata      ),
		.S_AXI_RRESP      (s_axi_rresp      ),
		.S_AXI_RVALID     (s_axi_rvalid     ),
		.S_AXI_RREADY     (s_axi_rready     )
	);

	// Add user logic here

	// User logic ends

	endmodule
