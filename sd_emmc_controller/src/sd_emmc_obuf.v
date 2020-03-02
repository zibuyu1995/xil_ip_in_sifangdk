// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_obuf.v
// Create : 2019-11-29 15:56:27
// Revised: 2019-11-29 16:47:53
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_obuf #(DATA_WIDTH = 1) (
		input  [DATA_WIDTH-1:0] do_i  ,
		output [DATA_WIDTH-1:0] do_pad
	);

	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_obuf
			OBUF OBUF_i (
				.O(do_pad[n]), // Buffer output (connect directly to top-level port)
				.I(do_i[n]  )  // Buffer input
			);
		end
	endgenerate

endmodule
