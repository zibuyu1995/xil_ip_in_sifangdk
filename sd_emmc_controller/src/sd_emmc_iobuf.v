// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_iobuf.v
// Create : 2019-11-29 15:48:53
// Revised: 2019-12-19 14:19:08
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_iobuf #(DATA_WIDTH = 1) (
		input  [DATA_WIDTH-1:0] dio_t  ,
		input  [DATA_WIDTH-1:0] dio_i  ,
		output [DATA_WIDTH-1:0] dio_o  ,
		inout  [DATA_WIDTH-1:0] dio_pad
	);


	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_iobuf
			IOBUF IOBUF_i (
				.O (dio_o[n]  ), // Buffer output
				.IO(dio_pad[n]), // Buffer inout port (connect directly to top-level port)
				.I (dio_i[n]  ), // Buffer input
				.T (dio_t[n]  )  // 3-state enable input, high=input, low=output
			);
		end
	endgenerate

endmodule
