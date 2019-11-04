// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : multadd.v
// Create : 2019-10-16 17:05:05
// Revised: 2019-10-17 10:34:34
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

(* use_dsp48="yes" *)module multadd #(parameter SIZEIN = 16) (
		input                      clk  , // Clock input
		input                      ce   , // Clock enable
		input                      rst  , // Reset
		input  signed [SIZEIN-1:0] a, b , // Inputs
		input  signed [2*SIZEIN:0] c    ,
		output signed [2*SIZEIN:0] p_out  // Output
	);

	// Declare registers for intermediate values
	reg signed [2*SIZEIN:0] c_q;

	reg signed [SIZEIN-1:0] a_reg, b_reg;
	reg signed [  SIZEIN:0] add_reg;
	reg signed [2*SIZEIN:0] c_reg, m_reg, p_reg;

	always @ (posedge clk)
		if (rst) 
			c_q <= 0;
		else if (ce)
			c_q <= c;

	always @ (posedge clk)
		if (rst) begin
			a_reg   <= 0;
			b_reg   <= 0;
			c_reg   <= 0;
			add_reg <= 0;
			m_reg   <= 0;
			p_reg   <= 0;
		end
		else if (ce) begin
			a_reg <= a;
			b_reg <= b;
			c_reg <= c_q;
			add_reg <= a + 0;
			m_reg <= add_reg * b_reg;
			p_reg <= m_reg + c_reg;
		end

	assign p_out = p_reg;

endmodule
