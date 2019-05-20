
`timescale 1 ns / 1 ps

	module zddaq_b_system_ctrl_v1_0 #
	(
		// Users to add parameters here
		parameter integer PULSE_WIDTH = 32,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here
		input wire ddr3_initialized,
		input wire ddr3_fifo_full,
		input wire ddr3_rw_error,

		output wire init_txn,
		output wire adc_sync,

		output wire [1:0] daq_mode,
		output wire [1:0] daq_trig_src,
		output wire [31:0] daq_trig_len,
		output wire daq_data_src,
		output wire daq_soft_trig,

		output wire [31:0] pcie_recv_len,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);

	wire ddr3_initialized_w;
	wire ddr3_fifo_full_w;
	wire ddr3_rw_error_w;
// Instantiation of Axi Bus Interface S00_AXI
	zddaq_b_system_ctrl_v1_0_S00_AXI #(
		.PULSE_WIDTH       (PULSE_WIDTH         ),
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) zddaq_b_system_ctrl_v1_0_S00_AXI_inst (
		.S_AXI_ACLK      (s00_axi_aclk      ),
		.S_AXI_ARESETN   (s00_axi_aresetn   ),
		.S_AXI_AWADDR    (s00_axi_awaddr    ),
		.S_AXI_AWPROT    (s00_axi_awprot    ),
		.S_AXI_AWVALID   (s00_axi_awvalid   ),
		.S_AXI_AWREADY   (s00_axi_awready   ),
		.S_AXI_WDATA     (s00_axi_wdata     ),
		.S_AXI_WSTRB     (s00_axi_wstrb     ),
		.S_AXI_WVALID    (s00_axi_wvalid    ),
		.S_AXI_WREADY    (s00_axi_wready    ),
		.S_AXI_BRESP     (s00_axi_bresp     ),
		.S_AXI_BVALID    (s00_axi_bvalid    ),
		.S_AXI_BREADY    (s00_axi_bready    ),
		.S_AXI_ARADDR    (s00_axi_araddr    ),
		.S_AXI_ARPROT    (s00_axi_arprot    ),
		.S_AXI_ARVALID   (s00_axi_arvalid   ),
		.S_AXI_ARREADY   (s00_axi_arready   ),
		.S_AXI_RDATA     (s00_axi_rdata     ),
		.S_AXI_RRESP     (s00_axi_rresp     ),
		.S_AXI_RVALID    (s00_axi_rvalid    ),
		.S_AXI_RREADY    (s00_axi_rready    ),
		.ddr3_initialized(ddr3_initialized_w),
		.ddr3_fifo_full  (ddr3_fifo_full_w  ),
		.ddr3_rw_error   (ddr3_rw_error_w   ),
		.init_txn        (init_txn          ),
		.adc_sync        (adc_sync          ),
		.daq_mode        (daq_mode          ),
		.daq_trig_src    (daq_trig_src      ),
		.daq_trig_len    (daq_trig_len      ),
		.daq_soft_trig   (daq_soft_trig     ),
		.pcie_recv_len   (pcie_recv_len     ),
		.daq_data_src    (daq_data_src      )
	);

	// Add user logic here
	cdc_sync_bits #(
		.NUM_OF_BITS(1),
		.ASYNC_CLK  (1)
	) cdc_sync_ddr3_initialized_i0 (
		.cdc_in    (ddr3_initialized  ),
		.out_resetn(s00_axi_aresetn   ),
		.out_clk   (s00_axi_aclk      ),
		.cdc_out   (ddr3_initialized_w)
	);

	cdc_sync_bits #(
		.NUM_OF_BITS(1),
		.ASYNC_CLK  (1)
	) cdc_sync_ddr3_fifo_full_i0 (
		.cdc_in    (ddr3_fifo_full  ),
		.out_resetn(s00_axi_aresetn ),
		.out_clk   (s00_axi_aclk    ),
		.cdc_out   (ddr3_fifo_full_w)
	);

	cdc_sync_bits #(
		.NUM_OF_BITS(1),
		.ASYNC_CLK  (1)
	) cdc_sync_ddr3_rw_error_i0 (
		.cdc_in    (ddr3_rw_error  ),
		.out_resetn(s00_axi_aresetn),
		.out_clk   (s00_axi_aclk   ),
		.cdc_out   (ddr3_rw_error_w)
	);


	// User logic ends

	endmodule
