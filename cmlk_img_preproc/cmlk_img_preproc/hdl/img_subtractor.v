// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : img_subtractor.v
// Create : 2019-11-13 15:17:05
// Revised: 2019-11-13 15:23:01
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module img_subtractor #(parameter WIDTH = 8) (
		input              clk  , // Clock
		input              rst_n, // Synchronous reset active low
		input  [WIDTH-1:0] a    ,
		input  [WIDTH-1:0] b    ,
		output [WIDTH-1:0] cout
	);

	wire is_less_zero;
	wire [WIDTH-1:0] cout_w;
	reg [WIDTH-1:0] cout_r;

	assign is_less_zero = (a < b);
	assign cout_w = a - b;

	always @ (posedge clk)
		if(!rst_n)
			cout_r <= 0;
		else if(is_less_zero)	
			cout_r <= 0;
		else
			cout_r <= cout_w;

	// output logic
	assign cout = cout_r;

endmodule