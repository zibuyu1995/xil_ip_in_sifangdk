
`timescale 1 ns / 1 ps

	module de3cd_system_ctrl_v1_0 #
	(
		// Users to add parameters here
		parameter VERSION = 1,
		parameter REVISION = 0,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 32
	)
	(
		// Users to add ports here
		output [15:0] tint_val,
		output tint_load,
		input region_indc,
		input region_data_valid,
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

	reg region_indc_r = 0;
	reg data_ready_r = 0;
	wire data_flag_clr;

	// Instantiation of Axi Bus Interface S_AXI
	de3cd_system_ctrl_v1_0_S_AXI #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
		.VERSION           (VERSION),
		.REVISION          (REVISION)
	) de3cd_system_ctrl_v1_0_S_AXI_inst (
		.S_AXI_ACLK       (s_axi_aclk   ),
		.S_AXI_ARESETN    (s_axi_aresetn),
		.S_AXI_AWADDR     (s_axi_awaddr ),
		.S_AXI_AWPROT     (s_axi_awprot ),
		.S_AXI_AWVALID    (s_axi_awvalid),
		.S_AXI_AWREADY    (s_axi_awready),
		.S_AXI_WDATA      (s_axi_wdata  ),
		.S_AXI_WSTRB      (s_axi_wstrb  ),
		.S_AXI_WVALID     (s_axi_wvalid ),
		.S_AXI_WREADY     (s_axi_wready ),
		.S_AXI_BRESP      (s_axi_bresp  ),
		.S_AXI_BVALID     (s_axi_bvalid ),
		.S_AXI_BREADY     (s_axi_bready ),
		.S_AXI_ARADDR     (s_axi_araddr ),
		.S_AXI_ARPROT     (s_axi_arprot ),
		.S_AXI_ARVALID    (s_axi_arvalid),
		.S_AXI_ARREADY    (s_axi_arready),
		.S_AXI_RDATA      (s_axi_rdata  ),
		.S_AXI_RRESP      (s_axi_rresp  ),
		.S_AXI_RVALID     (s_axi_rvalid ),
		.S_AXI_RREADY     (s_axi_rready ),
		.tint_val         (tint_val     ),
		.tint_load        (tint_load    ),
		.region_indc      (region_indc_r),
		.region_data_ready(data_ready_r ),
		.data_flag_clr    (data_flag_clr)
	);

	// Add user logic here
	always @ (posedge s_axi_aclk)
		if(!s_axi_aresetn)
			region_indc_r <= 0;
		else
			region_indc_r <= region_indc;

	always @ (posedge s_axi_aclk)
		if(!s_axi_aresetn)
			data_ready_r <= 0;
		else 
			case({region_data_valid, data_flag_clr})
				2'b00 : data_ready_r <= data_ready_r;
				2'b01 : data_ready_r <= 1'b0;
				2'b10 : data_ready_r <= 1'b1;
				2'b11 : data_ready_r <= 1'b1;
			endcase

	

	// User logic ends

	endmodule
