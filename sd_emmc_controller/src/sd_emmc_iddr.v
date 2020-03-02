// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_iddr.v
// Create : 2019-11-29 16:39:05
// Revised: 2019-12-20 09:59:12
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_iddr #(
		DATA_WIDTH   = 1                    ,
		DDR_CLK_EDGE = "SAME_EDGE_PIPELINED"  // "OPPOSITE_EDGE" "SAME_EDGE" or "SAME_EDGE_PIPELINED"
	) (
		input                     clk ,
		input                     rst ,
		//
		input  [  DATA_WIDTH-1:0] din ,
		output [2*DATA_WIDTH-1:0] dout
	);

	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_iddr
			IDDR #(
				.DDR_CLK_EDGE(DDR_CLK_EDGE), // "OPPOSITE_EDGE", "SAME_EDGE"
				.INIT_Q1     (1'b1        ), // Initial value of Q1: 1'b0 or 1'b1
				.INIT_Q2     (1'b1        ), // Initial value of Q2: 1'b0 or 1'b1
				.SRTYPE      ("SYNC"      )  // Set/Reset type: "SYNC" or "ASYNC"
			) IDDR_i (
				.Q1(dout[n]           ), // 1-bit output for positive edge of clock
				.Q2(dout[DATA_WIDTH+n]), // 1-bit output for negative edge of clock
				.C (clk               ), // 1-bit clock input
				.CE(1'b1              ), // 1-bit clock enable input
				.D (din[n]            ), // 1-bit DDR data input
				.R (1'b0              ), // 1-bit reset
				.S (rst               )  // 1-bit set
			);
		end
	endgenerate

endmodule
