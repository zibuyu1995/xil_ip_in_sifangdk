// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : test_top.v
// Create : 2019-12-06 09:47:43
// Revised: 2019-12-06 09:48:12
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module test_top(
		input pl_clk,
		//
		input emmc1_ds,
		inout [7:0] emmc1_data,
		inout emmc1_cmd,
		output emmc1_clk
    );


	wire clk_200m;
	wire clk_200m_90;
	wire glbl_rst_n;

	wire clk_div;
	wire clk_div_90;
	wire clk_div_locked;
	wire [15:0] divisor;

	wire clk_sel;
	wire sd_clk;
	wire sd_clk_90;
	reg sd_rst = 1;

	wire [1:0] setting_i;
	wire [39:0] cmd_i;
	wire start_i;
	wire cmd_dat_i;
	wire [119:0] response_o;
	wire finish_o;
	wire crc_ok_o;
	wire index_ok_o;
	wire cmd_oe_o;
	wire cmd_out_o;

	wire busy_idly;
	wire busy;
	wire [1:0] busy_q;

	wire ds_idly;
	wire ds;
	wire [1:0] ds_q;

	wire sd_clk_q;

	wire cmd_out_q;
	wire cmd_oe_q;
	
	clk_wiz_0 clk_wiz_0_i0 (.clk_out1(clk_200m), .clk_out2(clk_200m_90), .locked(glbl_rst_n), .clk_in1(pl_clk));

	sd_emmc_clock_divider sd_emmc_clock_divider_i0 (
		.clk          (clk_200m      ),
		.rst_n        (glbl_rst_n    ),
		.divisor      (divisor       ),
		.sd_clk_div   (clk_div       ),
		.sd_clk_div_90(clk_div_90    ),
		.locked       (clk_div_locked)
	);

	BUFGMUX BUFGMUX_i0 (
		.O (sd_clk  ), // 1-bit output: Clock output
		.I0(clk_200m), // 1-bit input: Clock input (S=0)
		.I1(clk_div ), // 1-bit input: Clock input (S=1)
		.S (sel_clk )  // 1-bit input: Clock select
	);

	BUFGMUX BUFGMUX_i1 (
		.O (sd_clk_90  ), // 1-bit output: Clock output
		.I0(clk_200m_90), // 1-bit input: Clock input (S=0)
		.I1(clk_div_90 ), // 1-bit input: Clock input (S=1)
		.S (sel_clk    )  // 1-bit input: Clock select
	);

	always @ (posedge sd_clk)
		sd_rst <= (sel_clk==1)?(~clk_div_locked):(~glbl_rst_n);


	sd_emmc_cmd_serial_host sd_emmc_cmd_serial_host_i0 (
		.sd_clk              (sd_clk),
		.rst                 (sd_rst),
		.setting_i           (setting_i),
		.cmd_i               (cmd_i),
		.start_i             (start_i),
		.response_o          (response_o),
		.crc_ok_o            (crc_ok_o),
		.index_ok_o          (index_ok_o),
		.finish_o            (finish_o),
		.cmd_dat_i           (cmd_dat_i),
		.cmd_out_o           (cmd_out_o),
		.cmd_oe_o            (cmd_oe_o),
		.command_inhibit_cmd ()
	);

	// iobuf
	IOBUF IOBUF_i0 (
		.O (cmd_dat_i), // Buffer output
		.IO(emmc1_cmd), // Buffer inout port (connect directly to top-level port)
		.I (cmd_out_q), // Buffer input
		.T (cmd_oe_q )  // 3-state enable input, high=input, low=output
	);

	IOBUF IOBUF_i1 (
		.O (busy      ), // Buffer output
		.IO(emmc1_data), // Buffer inout port (connect directly to top-level port)
		.I (1'b1      ), // Buffer input
		.T (1'b1      )  // 3-state enable input, high=input, low=output
	);

	OBUF OBUF_i0 (
		.O(emmc1_clk), // Buffer output (connect directly to top-level port)
		.I(sd_clk_q )  // Buffer input
	);

	IBUF IBUF_i0 (
		.O(ds      ), // Buffer output
		.I(emmc1_ds)  // Buffer input (connect directly to top-level port)
	);

	// debug
	reg [119:0] response_r;
	reg crc_ok_r;
	reg index_ok_r;

	wire start_x;
	wire finish_rise;

	wire [4:0] cnt_out_ds;
	wire [4:0] cnt_out_busy;

	wire [4:0] cnt_in;
	wire cnt_load;
	wire idelay_locked;
	wire polarity_sel;

	assign polarity_sel = 1'b0;

	always @ (posedge clk_200m)
		if(!glbl_rst_n) begin
			response_r <= 0;
			crc_ok_r <= 0;
			index_ok_r <= 0;
		end
		else if(finish_rise) begin
			response_r <= response_o;
			crc_ok_r <= crc_ok_o;
			index_ok_r <= index_ok_o;
		end

	edge_detect_0 edge_detect_0_i0 (
		.rst_n(~sd_rst), // input wire rst_n
		.clk  (sd_clk ), // input wire clk
		.sig  (start_x), // input wire sig
		.rise (start_i), // output wire rise
		.fall (       )  // output wire fall
	);

	edge_detect_0 edge_detect_0_i1 (
		.rst_n(glbl_rst_n ), // input wire rst_n
		.clk  (clk_200m   ), // input wire clk
		.sig  (finish_o   ), // input wire sig
		.rise (finish_rise), // output wire rise
		.fall (           )  // output wire fall
	);

	vio_0 vio_0_i0 (
		.clk       (clk_200m  ), // input wire clk
		.probe_in0 (glbl_rst_n), // input wire [0 : 0] probe_in0
		.probe_in1 (sd_rst    ), // input wire [0 : 0] probe_in1
		.probe_out0(divisor   ), // output wire [15 : 0] probe_out0
		.probe_out1(sel_clk   )  // output wire [0 : 0] probe_out1
	);

	vio_1 vio_1_i0 (
		.clk       (clk_200m   ), // input wire clk
		.probe_in0 (finish_rise), // input wire [0 : 0] probe_in0
		.probe_in1 (response_r ), // input wire [119 : 0] probe_in1
		.probe_in2 (crc_ok_r   ), // input wire [0 : 0] probe_in2
		.probe_in3 (index_ok_r ), // input wire [0 : 0] probe_in3
		.probe_in4 (1'b0       ), // input wire [0 : 0] probe_in4
		.probe_in5 (busy_idly  ), // input wire [0 : 0] probe_in5
		.probe_out0(cmd_i      ), // output wire [39 : 0] probe_out0
		.probe_out1(setting_i  ), // output wire [1 : 0] probe_out1
		.probe_out2(start_x    )  // output wire [0 : 0] probe_out2
	);

	vio_2 vio_2_i0 (
		.clk       (clk_200m     ), // input wire clk
		.probe_in0 (cnt_out_ds   ), // input wire [4 : 0] probe_in0
		.probe_in1 (cnt_out_busy ), // input wire [4 : 0] probe_in1
		.probe_in2 (idelay_locked), // input wire [0 : 0] probe_in2
		.probe_out0(cnt_in       ), // output wire [4 : 0] probe_out0
		.probe_out1(cnt_load     )
	);

	ila_0 ila_0_i0 (
		.clk   (clk_200m ), // input wire clk
		.probe0(clk_div  ), // input wire [0:0]  probe0
		.probe1(cmd_dat_i), // input wire [0:0]  probe1
		.probe2(cmd_out_o), // input wire [0:0]  probe2
		.probe3(cmd_oe_o ), // input wire [0:0]  probe3
		.probe4(ds_q     ), // input wire [1:0]  probe4
		.probe5(busy_q   )  // input wire [1:0]  probe5
	);

	(* IODELAY_GROUP = "io_delay_grp" *) 
	IDELAYCTRL IDELAYCTRL_inst (
		.RDY   (idelay_locked), // 1-bit output: Ready output
		.REFCLK(clk_200m     ), // 1-bit input: Reference clock input
		.RST   (~glbl_rst_n  )  // 1-bit input: Active high reset input
	);

	(* IODELAY_GROUP = "io_delay_grp" *)
	IDELAYE2 #(
		.CINVCTRL_SEL         ("FALSE"   ), // Enable dynamic clock inversion (FALSE, TRUE)
		.DELAY_SRC            ("IDATAIN" ), // Delay input (IDATAIN, DATAIN)
		.HIGH_PERFORMANCE_MODE("TRUE"    ), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
		.IDELAY_TYPE          ("VAR_LOAD"), // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
		.IDELAY_VALUE         (0         ), // Input delay tap setting (0-31)
		.PIPE_SEL             ("FALSE"   ), // Select pipelined mode, FALSE, TRUE
		.REFCLK_FREQUENCY     (200.0     ), // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
		.SIGNAL_PATTERN       ("DATA"    )  // DATA, CLOCK input signal
	) IDELAYE2_i0 (
		.CNTVALUEOUT(cnt_out_ds  ), // 5-bit output: Counter value output
		.DATAOUT    (ds_idly     ), // 1-bit output: Delayed data output
		.C          (clk_200m    ), // 1-bit input: Clock input
		.CE         (1'b0        ), // 1-bit input: Active high enable increment/decrement input
		.CINVCTRL   (polarity_sel), // 1-bit input: Dynamic clock inversion input
		.CNTVALUEIN (cnt_in      ), // 5-bit input: Counter value input
		.DATAIN     (1'b0        ), // 1-bit input: Internal delay data input
		.IDATAIN    (ds          ), // 1-bit input: Data input from the I/O
		.INC        (1'b0        ), // 1-bit input: Increment / Decrement tap delay input
		.LD         (cnt_load    ), // 1-bit input: Load IDELAY_VALUE input
		.LDPIPEEN   (1'b0        ), // 1-bit input: Enable PIPELINE register to load data input
		.REGRST     (1'b0        )  // 1-bit input: Active-high reset tap-delay input
	);

	(* IODELAY_GROUP = "io_delay_grp" *)
	IDELAYE2 #(
		.CINVCTRL_SEL         ("FALSE"   ), // Enable dynamic clock inversion (FALSE, TRUE)
		.DELAY_SRC            ("IDATAIN" ), // Delay input (IDATAIN, DATAIN)
		.HIGH_PERFORMANCE_MODE("TRUE"    ), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
		.IDELAY_TYPE          ("VAR_LOAD"), // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
		.IDELAY_VALUE         (0         ), // Input delay tap setting (0-31)
		.PIPE_SEL             ("FALSE"   ), // Select pipelined mode, FALSE, TRUE
		.REFCLK_FREQUENCY     (200.0     ), // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
		.SIGNAL_PATTERN       ("DATA"    )  // DATA, CLOCK input signal
	) IDELAYE2_i1 (
		.CNTVALUEOUT(cnt_out_busy), // 5-bit output: Counter value output
		.DATAOUT    (busy_idly   ), // 1-bit output: Delayed data output
		.C          (clk_200m    ), // 1-bit input: Clock input
		.CE         (1'b0        ), // 1-bit input: Active high enable increment/decrement input
		.CINVCTRL   (polarity_sel), // 1-bit input: Dynamic clock inversion input
		.CNTVALUEIN (cnt_in      ), // 5-bit input: Counter value input
		.DATAIN     (1'b0        ), // 1-bit input: Internal delay data input
		.IDATAIN    (busy        ), // 1-bit input: Data input from the I/O
		.INC        (1'b0        ), // 1-bit input: Increment / Decrement tap delay input
		.LD         (cnt_load    ), // 1-bit input: Load IDELAY_VALUE input
		.LDPIPEEN   (1'b0        ), // 1-bit input: Enable PIPELINE register to load data input
		.REGRST     (1'b0        )  // 1-bit input: Active-high reset tap-delay input
	);

	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED"
		.INIT_Q1     (1'b0                 ), // Initial value of Q1: 1'b0 or 1'b1
		.INIT_Q2     (1'b0                 ), // Initial value of Q2: 1'b0 or 1'b1
		.SRTYPE      ("SYNC"               )  // Set/Reset type: "SYNC" or "ASYNC"
	) IDDR_i0 (
		.Q1(ds_q[0] ), // 1-bit output for positive edge of clock
		.Q2(ds_q[1] ), // 1-bit output for negative edge of clock
		.C (clk_200m), // 1-bit clock input
		.CE(1'b1    ), // 1-bit clock enable input
		.D (ds_idly ), // 1-bit DDR data input
		.R (1'b0    ), // 1-bit reset
		.S (1'b0    )  // 1-bit set
	);

	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED"
		.INIT_Q1     (1'b0                 ), // Initial value of Q1: 1'b0 or 1'b1
		.INIT_Q2     (1'b0                 ), // Initial value of Q2: 1'b0 or 1'b1
		.SRTYPE      ("SYNC"               )  // Set/Reset type: "SYNC" or "ASYNC"
	) IDDR_i1 (
		.Q1(busy_q[0]), // 1-bit output for positive edge of clock
		.Q2(busy_q[1]), // 1-bit output for negative edge of clock
		.C (clk_200m ), // 1-bit clock input
		.CE(1'b1     ), // 1-bit clock enable input
		.D (busy_idly), // 1-bit DDR data input
		.R (1'b0     ), // 1-bit reset
		.S (1'b0     )  // 1-bit set
	);

	ODDR #(
		.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
		.INIT        (1'b0           ), // Initial value of Q: 1'b0 or 1'b1
		.SRTYPE      ("SYNC"         )  // Set/Reset type: "SYNC" or "ASYNC"
	) ODDR_i0 (
		.Q (sd_clk_q ), // 1-bit DDR output
		.C (sd_clk_90), // 1-bit clock input
		.CE(1'b1     ), // 1-bit clock enable input
		.D1(1'b1     ), // 1-bit data input (positive edge)
		.D2(1'b0     ), // 1-bit data input (negative edge)
		.R (1'b0     ), // 1-bit reset
		.S (1'b0     )  // 1-bit set
	);

	ODDR #(
		.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
		.INIT        (1'b1           ), // Initial value of Q: 1'b0 or 1'b1
		.SRTYPE      ("SYNC"         )  // Set/Reset type: "SYNC" or "ASYNC"
	) ODDR_i1 (
		.Q (cmd_out_q), // 1-bit DDR output
		.C (sd_clk   ), // 1-bit clock input
		.CE(1'b1     ), // 1-bit clock enable input
		.D1(cmd_out_o), // 1-bit data input (positive edge)
		.D2(cmd_out_o), // 1-bit data input (negative edge)
		.R (sd_rst   ), // 1-bit reset
		.S (1'b0     )  // 1-bit set
	);

	FDRE #(.INIT(1'b1)) FDRE_i0 (
		.Q (cmd_oe_q), // 1-bit Data output
		.C (sd_clk  ), // 1-bit Clock input
		.CE(1'b1    ), // 1-bit Clock enable input
		.R (sd_rst  ), // 1-bit Synchronous reset input
		.D (cmd_oe_o)  // 1-bit Data input
	);


endmodule
