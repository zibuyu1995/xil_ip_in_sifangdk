
`timescale 1 ns / 1 ps

	module cmlk_system_ctrl_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 7
	)
	(
		// Users to add ports here
		// timing control
		output [15:0] cmos_freq,
		output [15:0] cmos_width,
		output [31:0] laser_freq,
		output [31:0] laser_width,
		output [31:0] frame_gate_width_a,
		output [31:0] frame_gate_delay_a,
		output [31:0] frame_gate_width_b,
		output [31:0] frame_gate_delay_b,
		output [7:0] tim_cycles_m,
		output [7:0] delay_step_delta_t,

		output       load_param,

		// imaging algorithm control
		output [15:0] frame_delay_a,
		output [15:0] frame_delay_b,
		output [15:0] gate_width,
		output [7:0] threshold,

		// misc
		output [15:0] bg_frame_deci_n,

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
	cmlk_system_ctrl_v1_0_S_AXI #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) cmlk_system_ctrl_v1_0_S_AXI_inst (
		.cmos_freq         (cmos_freq         ),
		.cmos_width        (cmos_width        ),
		.laser_freq        (laser_freq        ),
		.laser_width       (laser_width       ),
		.frame_gate_width_a(frame_gate_width_a),
		.frame_gate_delay_a(frame_gate_delay_a),
		.frame_gate_width_b(frame_gate_width_b),
		.frame_gate_delay_b(frame_gate_delay_b),
		.tim_cycles_m      (tim_cycles_m      ),
		.delay_step_delta_t(delay_step_delta_t),
		.load_param        (load_param        ),
		.frame_delay_a     (frame_delay_a     ),
		.frame_delay_b     (frame_delay_b     ),
		.gate_width        (gate_width        ),
		.threshold         (threshold         ),
		.bg_frame_deci_n   (bg_frame_deci_n   ),
		.S_AXI_ACLK        (s_axi_aclk        ),
		.S_AXI_ARESETN     (s_axi_aresetn     ),
		.S_AXI_AWADDR      (s_axi_awaddr      ),
		.S_AXI_AWPROT      (s_axi_awprot      ),
		.S_AXI_AWVALID     (s_axi_awvalid     ),
		.S_AXI_AWREADY     (s_axi_awready     ),
		.S_AXI_WDATA       (s_axi_wdata       ),
		.S_AXI_WSTRB       (s_axi_wstrb       ),
		.S_AXI_WVALID      (s_axi_wvalid      ),
		.S_AXI_WREADY      (s_axi_wready      ),
		.S_AXI_BRESP       (s_axi_bresp       ),
		.S_AXI_BVALID      (s_axi_bvalid      ),
		.S_AXI_BREADY      (s_axi_bready      ),
		.S_AXI_ARADDR      (s_axi_araddr      ),
		.S_AXI_ARPROT      (s_axi_arprot      ),
		.S_AXI_ARVALID     (s_axi_arvalid     ),
		.S_AXI_ARREADY     (s_axi_arready     ),
		.S_AXI_RDATA       (s_axi_rdata       ),
		.S_AXI_RRESP       (s_axi_rresp       ),
		.S_AXI_RVALID      (s_axi_rvalid      ),
		.S_AXI_RREADY      (s_axi_rready      )
	);

	// Add user logic here

	// User logic ends

	endmodule
