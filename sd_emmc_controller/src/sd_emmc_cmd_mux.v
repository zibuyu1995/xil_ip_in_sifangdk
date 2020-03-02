// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_cmd_mux.v
// Create : 2019-12-18 16:35:52
// Revised: 2019-12-19 10:29:49
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_cmd_mux(
		input sd_clk,
		input rst,
		// mux control
		input [1:0] sel_mux,
		// mux in 0
		input [1:0] setting_0,
		input [39:0] cmd_0,
		input start_xfr_0,
		// mux in 1
		input [1:0] setting_1,
		input [39:0] cmd_1,
		input start_xfr_1,
		// mux in 2
		input [1:0] setting_2,
		input [39:0] cmd_2,
		input start_xfr_2,
		// mux in 3
		input [1:0] setting_3,
		input [39:0] cmd_3,
		input start_xfr_3,
		// mux out
		output [1:0] setting_o,
		output [39:0] cmd_o,
		output start_xfr_o
    );

	localparam MUX0 = 2'b00;
	localparam MUX1 = 2'b01;
	localparam MUX2 = 2'b10;
	localparam MUX3 = 2'b11;

	reg [1:0] setting_r;
	reg [39:0] cmd_r;
	reg start_xfr_r;

	always @ (posedge sd_clk)
		if(rst) begin
			setting_r <= 0;
			cmd_r <= 0;
			start_xfr_r <= 0;
		end
		else
			case (sel_mux)
				MUX0 : begin
					setting_r <= setting_0;
					cmd_r <= cmd_0;
					start_xfr_r <= start_xfr_0;
				end
				MUX1 : begin
					setting_r <= setting_1;
					cmd_r <= cmd_1;
					start_xfr_r <= start_xfr_1;
				end
				MUX2 : begin
					setting_r <= setting_2;
					cmd_r <= cmd_2;
					start_xfr_r <= start_xfr_2;
				end
				MUX3 : begin
					setting_r <= setting_3;
					cmd_r <= cmd_3;
					start_xfr_r <= start_xfr_3;
				end
				default : begin
					setting_r <= setting_0;
					cmd_r <= cmd_0;
					start_xfr_r <= start_xfr_0;
				end
			endcase

	// output logic
	assign setting_o = setting_r;
	assign cmd_o = cmd_r;
	assign start_xfr_o = start_xfr_r;
	
endmodule
