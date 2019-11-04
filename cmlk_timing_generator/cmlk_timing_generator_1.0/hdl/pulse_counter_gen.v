// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : pulse_counter_gen.v
// Create : 2019-10-18 09:36:17
// Revised: 2019-11-04 11:26:53
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module pulse_counter_gen(
		input clk,
		input rst_n,
		//
		input [31:0] laser_freq,
		input cmos_trig_pulse,
		input [15:0] bg_frame_deci_n,
		//
		output [31:0] cnt_out,
		output [1:0] frame_type
    );

	localparam FRAME_BG = 2'b00;
	localparam FRAME_A = 2'b01;
	localparam FRAME_B = 2'b10;

	reg cmos_trig_pulse_q;
	wire cmos_trig_pulse_rise;

	reg [31:0] pulse_cnt;
	reg [31:0] pulse_cnt_r;

	reg [15:0] frame_cnt;
	reg [1:0] frame_type_r;

	reg init_flag;

	always @ (posedge clk)
		if(!rst_n)
			init_flag <= 0;
		else if(cmos_trig_pulse_rise)
			init_flag <= 1;
		else
			init_flag <= init_flag;

	always @ (posedge clk)
		if(!rst_n)
			cmos_trig_pulse_q <= 0;
		else
			cmos_trig_pulse_q <= cmos_trig_pulse;

	assign cmos_trig_pulse_rise = ({cmos_trig_pulse_q, cmos_trig_pulse}==2'b01);

	always @ (posedge clk)
		if(!rst_n || cmos_trig_pulse_rise)
			pulse_cnt <= 0;
		else if(init_flag)
			if(pulse_cnt >= laser_freq)
				pulse_cnt <= pulse_cnt - laser_freq;
			else
				pulse_cnt <= pulse_cnt + 10;
		else
			pulse_cnt <= pulse_cnt;

	always @ (posedge clk)
		if(!rst_n)
			frame_cnt <= 16'hffff;
		else if(cmos_trig_pulse_rise)
			if(frame_cnt >= bg_frame_deci_n)
				frame_cnt <= 0;
			else
				frame_cnt <= frame_cnt + 1;
		else
			frame_cnt <= frame_cnt; 

	always @ (posedge clk)
		if(!rst_n)
			frame_type_r <= FRAME_BG;
		else if(init_flag)
			if(frame_cnt==0) 
				frame_type_r <= FRAME_BG;
			else if(frame_cnt[0]==1'b1)
				frame_type_r <= FRAME_A;
			else
				frame_type_r <= FRAME_B;
		else
			frame_type_r <= frame_type_r;

	// pipeline stage 2 for alignment of frame type
	always @ (posedge clk)
		if(!rst_n)
			pulse_cnt_r <= 0;
		else
			pulse_cnt_r <= pulse_cnt;

	assign cnt_out = pulse_cnt_r;
	assign frame_type = frame_type_r;

endmodule
