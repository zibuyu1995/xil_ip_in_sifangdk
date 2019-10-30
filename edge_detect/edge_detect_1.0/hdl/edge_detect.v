// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : edge_detect.v
// Create : 2019-10-21 17:00:21
// Revised: 2019-10-21 17:01:06
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

	reg [1:0] sig_reg;

	always @(posedge clk)
		if (rst_n == 1'b0)
			sig_reg <= 2'b00;
		else
			sig_reg <= {sig_reg[0], sig};

	assign rise = sig_reg[0] == 1'b1 && sig_reg[1] == 1'b0 ? 1'b1 : 1'b0;
	assign fall = sig_reg[0] == 1'b0 && sig_reg[1] == 1'b1 ? 1'b1 : 1'b0;

endmodule