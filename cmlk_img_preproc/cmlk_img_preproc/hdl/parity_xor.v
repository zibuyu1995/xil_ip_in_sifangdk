// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : parity_xor.v
// Create : 2019-11-15 11:03:07
// Revised: 2019-11-15 11:08:37
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module parity_xor#(parameter DATA_WIDTH = 32)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [DATA_WIDTH-1:0] data_in,
	input parity_en,
	output [DATA_WIDTH-1:0] data_out
);

	wire [DATA_WIDTH-1:0] parity_res;
	reg [DATA_WIDTH-1:0] parity_reg;

	assign parity_res = data_in ^ parity_reg;

	always @ (posedge clk)
		if(!rst_n)
			parity_reg <= 0;
		else if(parity_en)
			parity_reg <= parity_res;
		else
			parity_reg <= parity_reg;

	assign data_out = parity_reg;

endmodule