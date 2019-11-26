// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : edge_detect.v
// Create : 2019-10-21 17:00:21
// Revised: 2019-11-25 10:58:06
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module edge_detect (
	input  rst_n,
	input  clk  ,
	input  sig  ,
	output rise ,
	output fall
);

	reg sig_reg;

	always @(posedge clk)
		if (rst_n == 1'b0)
			sig_reg <= 2'b00;
		else
			sig_reg <= sig;

	assign rise = sig == 1'b1 && sig_reg == 1'b0 ? 1'b1 : 1'b0;
	assign fall = sig == 1'b0 && sig_reg == 1'b1 ? 1'b1 : 1'b0;

endmodule