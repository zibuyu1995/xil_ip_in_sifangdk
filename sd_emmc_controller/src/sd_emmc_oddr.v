// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_oddr.v
// Create : 2019-11-29 17:12:03
// Revised: 2019-11-29 17:49:25
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_oddr #(
		DATA_WIDTH   = 1              ,
		DDR_CLK_EDGE = "OPPOSITE_EDGE"  // "OPPOSITE_EDGE" or "SAME_EDGE" 
	) (
		input                     clk ,
		input                     rst ,
		//
		input  [2*DATA_WIDTH-1:0] din ,
		output [  DATA_WIDTH-1:0] dout
	);

	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_oddr
			ODDR #(
				.DDR_CLK_EDGE(DDR_CLK_EDGE), // "OPPOSITE_EDGE" or "SAME_EDGE"
				.INIT        (1'b0        ), // Initial value of Q: 1'b0 or 1'b1
				.SRTYPE      ("SYNC"      )  // Set/Reset type: "SYNC" or "ASYNC"
			) ODDR_i (
				.Q (dout[n]          ), // 1-bit DDR output
				.C (clk              ), // 1-bit clock input
				.CE(1'b1             ), // 1-bit clock enable input
				.D1(din[n]           ), // 1-bit data input (positive edge)
				.D2(din[DATA_WIDTH+n]), // 1-bit data input (negative edge)
				.R (rst              ), // 1-bit reset
				.S (1'b0             )  // 1-bit set
			);
		end
	endgenerate

endmodule
