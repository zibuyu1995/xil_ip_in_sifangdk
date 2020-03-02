// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_idelay.v
// Create : 2019-11-29 16:54:12
// Revised: 2020-03-02 16:06:30
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_idelay #(
		DATA_WIDTH    = 1                   ,
		IODELAY_GROUP = "dev_if_delay_group"
	) (
		input                       clk        ,
		input                       rst        ,
		// config interface
		input  [(DATA_WIDTH*5)-1:0] cntval_in  ,
		input                       cntval_load,
		output [(DATA_WIDTH*5)-1:0] cntval_out ,
		// data interface
		input  [    DATA_WIDTH-1:0] din_ibuf   ,
		output [    DATA_WIDTH-1:0] din_idelay 
	);

	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_idelay
			(* IODELAY_GROUP = IODELAY_GROUP *)
			IDELAYE2 #(
				.CINVCTRL_SEL         ("FALSE"   ), // Enable dynamic clock inversion (FALSE, TRUE)
				.DELAY_SRC            ("IDATAIN" ), // Delay input (IDATAIN, DATAIN)
				.HIGH_PERFORMANCE_MODE("TRUE"    ), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
				.IDELAY_TYPE          ("VAR_LOAD"), // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
				.IDELAY_VALUE         (0         ), // Input delay tap setting (0-31)
				.PIPE_SEL             ("FALSE"   ), // Select pipelined mode, FALSE, TRUE
				.REFCLK_FREQUENCY     (200.0     ), // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
				.SIGNAL_PATTERN       ("DATA"    )  // DATA, CLOCK input signal
			) IDELAYE2_i (
				.CNTVALUEOUT(cntval_out[((5*n)+4):(5*n)]), // 5-bit output: Counter value output
				.DATAOUT    (din_idelay[n]              ), // 1-bit output: Delayed data output
				.C          (clk                        ), // 1-bit input: Clock input
				.CE         (1'b0                       ), // 1-bit input: Active high enable increment/decrement input
				.CINVCTRL   (1'b0                       ), // 1-bit input: Dynamic clock inversion input
				.CNTVALUEIN (cntval_in[((5*n)+4):(5*n)] ), // 5-bit input: Counter value input
				.DATAIN     (1'b0                       ), // 1-bit input: Internal delay data input
				.IDATAIN    (din_ibuf[n]                ), // 1-bit input: Data input from the I/O
				.INC        (1'b0                       ), // 1-bit input: Increment / Decrement tap delay input
				.LD         (cntval_load                ), // 1-bit input: Load IDELAY_VALUE input
				.LDPIPEEN   (1'b0                       ), // 1-bit input: Enable PIPELINE register to load data input
				.REGRST     (rst                        )  // 1-bit input: Active-high reset tap-delay input
			);
		end
	endgenerate
	

endmodule
