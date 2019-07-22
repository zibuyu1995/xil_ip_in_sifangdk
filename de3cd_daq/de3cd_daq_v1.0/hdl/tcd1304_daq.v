// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : tcd1304_daq.v
// Create : 2019-07-06 10:06:34
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module tcd1304_daq(
		input clk,
		input rst_n,
		// data in
		input [15:0] tcd1304_din,
		input tcd1304_din_valid,
		input tcd1304_icg,
		// data out
		output [15:0] tcd1304_dout,
		output tcd1304_dout_valid,
		output tcd1304_frame_start
    );


	localparam DUMMY_FRONT1 = 16;
	localparam LIGHT_SHIELD = 13;
	localparam DUMMY_FRONT2 = 3;
	localparam SIGNAL_ELEMENTS = 3648;
	localparam DUMMY_END = 14;

	localparam VALID_SIGNAL = DUMMY_FRONT + SIGNAL_ELEMENTS + 1;
	localparam DUMMY_FRONT = DUMMY_FRONT1 + LIGHT_SHIELD + DUMMY_FRONT2;
	localparam TOTAL_ELEMENTS = DUMMY_FRONT + SIGNAL_ELEMENTS + DUMMY_END;
	localparam LAST_NUM = TOTAL_ELEMENTS + 1;

	reg icg_r = 0;
	wire icg_rise_edge;
	reg frame_start_r = 0;

	reg frame_en = 0;
	reg [11:0] frame_cnt = 0;

	reg [15:0] dout_r = 0;
	reg dout_valid_r = 0;
	wire data_hit;


	// detect icg
	always @ (posedge clk)
		if(!rst_n)
			icg_r <= 0;
		else 
			icg_r <= tcd1304_icg;

	assign icg_rise_edge = ({icg_r, tcd1304_icg}==2'b01);

	// frame start generator
	always @ (posedge clk)
		if(!rst_n)
			frame_start_r <= 0;
		else if(icg_rise_edge)
			frame_start_r <= 1;
		else
			frame_start_r <= 0;

	// frame generator
	always @ (posedge clk)
		if(!rst_n)
			frame_en <= 0;
		else if(icg_rise_edge)
			frame_en <= 1;
		else if(frame_cnt==TOTAL_ELEMENTS+1)
			frame_en <= 0;
		else
			frame_en <= frame_en;


	always @ (posedge clk)
		if(!rst_n)
			frame_cnt <= 0;
		else 
			case(frame_cnt)
				0 : begin
					if(icg_rise_edge)
						frame_cnt <= frame_cnt + 1'b1;
					else
						frame_cnt <= 0;
				end
				TOTAL_ELEMENTS : begin
					if(tcd1304_din_valid)
						frame_cnt <= frame_cnt + 1'b1;
					else
						frame_cnt <= frame_cnt;
				end

				LAST_NUM : begin
					frame_cnt <= 0;
				end

				default : begin
					if(tcd1304_din_valid)
						frame_cnt <= frame_cnt + 1'b1;
					else
						frame_cnt <= frame_cnt;
				end
			endcase

	// data generator
	assign data_hit = (frame_cnt>DUMMY_FRONT)&&(frame_cnt<VALID_SIGNAL);

	always @ (posedge clk)
		if(!rst_n)
			dout_valid_r <= 0;
		else if(data_hit)
			dout_valid_r <= tcd1304_din_valid;
		else
			dout_valid_r <= 0;

	always @ (posedge clk)
		if(!rst_n)
			dout_r <= 0;
		else if(data_hit)
			dout_r <= tcd1304_din;
		else
			dout_r <= 0;

	assign tcd1304_dout = dout_r;
	assign tcd1304_dout_valid = dout_valid_r;
	assign tcd1304_frame_start = frame_start_r;

endmodule
