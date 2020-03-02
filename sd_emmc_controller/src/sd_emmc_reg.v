// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_reg.v
// Create : 2019-11-29 17:53:23
// Revised: 2019-12-19 15:43:19
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_reg #(
		DATA_WIDTH   = 1     ,
		PLACE_IN_IOB = "FALSE"
	) (
		input                   clk ,
		input                   rst ,
		//
		input  [DATA_WIDTH-1:0] din ,
		output [DATA_WIDTH-1:0] dout
	);

	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_dff
			(* IOB=PLACE_IN_IOB *)
			FDSE #(.INIT(1'b1)) FDSE_i (
				.Q (dout[n]), // 1-bit Data output
				.C (clk    ), // 1-bit Clock input
				.CE(1'b1   ), // 1-bit Clock enable input
				.S (rst    ), // 1-bit Synchronous reset input
				.D (din[n] )  // 1-bit Data input
			);
		end
	endgenerate

endmodule
