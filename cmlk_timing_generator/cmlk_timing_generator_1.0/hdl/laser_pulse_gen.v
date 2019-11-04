// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : laser_pulse_gen.v
// Create : 2019-10-16 14:16:01
// Revised: 2019-10-17 11:00:53
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module laser_pulse_gen (
		input         clk,
		input         rst_n,
		//
		input  [31:0] laser_cnt_in,
		input  [31:0] laser_width,
		input  [ 1:0] frame_type,
		//
		output [ 9:0] laser_data_out
	);

	localparam FRAME_BG = 2'b00;
	localparam FRAME_A = 2'b01;
	localparam FRAME_B = 2'b10;

	wire is_bg_frame;
	wire [9:0] bit_q;

	reg [9:0] laser_data_out_r;

	genvar inst;

	generate
		for(inst=0; inst<10; inst=inst+1) begin
			cnt_bit_select #(
				.CNT_WIDTH(32  ),
				.BIT_INDEX(inst)
			) cnt_bit_select_i (
				.clk        (clk         ),
				.rst_n      (rst_n       ),
				.cnt_in     (laser_cnt_in),
				.cmp_rise_in(32'd0       ),
				.cmp_fall_in(laser_width ),
				.bit_q      (bit_q[inst] )
			);
		end
	endgenerate

	always @ (posedge clk)
		if(!rst_n)
			laser_data_out_r <= 0;
		else
			laser_data_out_r <= (is_bg_frame==1'b1)?10'd0:bit_q;

	assign is_bg_frame = (frame_type==FRAME_BG);

	assign laser_data_out = laser_data_out_r;

endmodule
