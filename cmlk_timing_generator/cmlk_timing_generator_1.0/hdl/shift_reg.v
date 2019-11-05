// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : shift_reg.v
// Create : 2019-11-04 17:23:04
// Revised: 2019-11-04 17:34:48
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module shift_reg#(
		parameter PLACE_IN_IOB = "true",
		parameter DELAY_CYCLE = 2 // min number is 2
	)(
		input clk,
		input rst_n,
		//
		input din,
		output dout
    );

    localparam SHIFT_REG_WIDTH = (DELAY_CYCLE>=2)?(DELAY_CYCLE - 1):2;

	reg [SHIFT_REG_WIDTH-1:0] shift_reg = {SHIFT_REG_WIDTH{1'b0}};
	(* IOB=PLACE_IN_IOB *)reg out_reg;

	generate
		if(DELAY_CYCLE==2) begin
			always @ (posedge clk)
				shift_reg <= din;
		end
		else begin
			always @ (posedge clk)
				shift_reg <= {shift_reg[SHIFT_REG_WIDTH-2:0], din};
		end
	endgenerate

	always @ (posedge clk)
		if(!rst_n)
			out_reg <= 0;
		else
			out_reg <= shift_reg[SHIFT_REG_WIDTH-1];

	assign dout = out_reg;

endmodule
