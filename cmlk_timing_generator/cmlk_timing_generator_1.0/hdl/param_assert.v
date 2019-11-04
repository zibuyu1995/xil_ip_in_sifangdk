// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : param_assert.v
// Create : 2019-10-18 11:40:48
// Revised: 2019-11-04 14:26:38
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module param_assert(
		input clk,
		input rst_n,
		//
		input [15:0] cmos_freq,
		input [15:0] cmos_width,
		input [31:0] laser_freq,
		input [31:0] laser_width,
		input [31:0] frame_gate_width_a,
		input [31:0] frame_gate_delay_a,
		input [31:0] frame_gate_width_b,
		input [31:0] frame_gate_delay_b,
		input [7:0] tim_cycles_m,
		input [7:0] delay_step_delta_t,
		input [15:0] bg_frame_deci_n,
		input       load_param,
		// 
		output [15:0] cmos_freq_o,
		output [15:0] cmos_width_o,
		output [31:0] laser_freq_o,
		output [31:0] laser_width_o,
		output [31:0] frame_gate_width_a_o,
		output [31:0] frame_gate_delay_a_o,
		output [31:0] frame_gate_width_b_o,
		output [31:0] frame_gate_delay_b_o,
		output [7:0] tim_cycles_m_o,
		output [7:0] delay_step_delta_t_o,
		output [15:0] bg_frame_deci_n_o
    );

	localparam MAX_CMOS_FREQ = 10_000 - 1;
	localparam MAX_CMOS_WIDTH = 10_000 - 1;
	localparam MAX_LASER_FREQ = 1_000_000_000 - 1;
	localparam MAX_LASER_WIDTH = 1_000_000_000 - 1;
	localparam MAX_FRAME_GATE_WIDTH_A = 1_000_000_000 - 1;
	localparam MAX_FRAME_GATE_DELAY_A = 1_000_000_000 - 1;
	localparam MAX_FRAME_GATE_WIDTH_B = 1_000_000_000 - 1;
	localparam MAX_FRAME_GATE_DELAY_B = 1_000_000_000 - 1;


	reg [15:0] cmos_freq_r;
	reg [15:0] cmos_width_r;
	reg [31:0] laser_freq_r;
	reg [31:0] laser_width_r;
	reg [31:0] frame_gate_width_a_r;
	reg [31:0] frame_gate_delay_a_r;
	reg [31:0] frame_gate_width_b_r;
	reg [31:0] frame_gate_delay_b_r;
	reg [7:0] tim_cycles_m_r;
	reg [7:0] delay_step_delta_t_r;
	reg [15:0] bg_frame_deci_n_r;

	wire load_param_p;

	wire cmos_freq_ovf;
	wire cmos_width_ovf;
	wire laser_freq_ovf;
	wire laser_width_ovf;
	wire frame_gate_width_a_ovf;
	wire frame_gate_width_b_ovf;
	wire frame_gate_delay_a_ovf;
	wire frame_gate_delay_b_ovf;


	assign cmos_freq_ovf = (cmos_freq>MAX_CMOS_FREQ);
	assign cmos_width_ovf = (cmos_width>MAX_CMOS_WIDTH);
	assign laser_freq_ovf = (laser_freq>MAX_LASER_FREQ);
	assign laser_width_ovf = (laser_width>MAX_LASER_WIDTH);
	assign frame_gate_width_a_ovf = (frame_gate_width_a>MAX_FRAME_GATE_WIDTH_A);
	assign frame_gate_width_b_ovf = (frame_gate_width_b>MAX_FRAME_GATE_WIDTH_B);
	assign frame_gate_delay_a_ovf = (frame_gate_delay_a>MAX_FRAME_GATE_DELAY_A);
	assign frame_gate_delay_b_ovf = (frame_gate_delay_b>MAX_FRAME_GATE_DELAY_B);

	edge_detect i_edge_detect (.rst_n(rst_n), .clk(clk), .sig(load_param), .rise(load_param_p), .fall());


	always @ (posedge clk)
		if(!rst_n)
			cmos_freq_r <= 0;
		else if(load_param_p)
			cmos_freq_r <= cmos_freq_ovf?MAX_CMOS_FREQ:cmos_freq;
		else
			cmos_freq_r <= cmos_freq_r;

	always @ (posedge clk)
		if(!rst_n)
			cmos_width_r <= 0;
		else if(load_param_p)
			cmos_width_r <= cmos_width_ovf?MAX_CMOS_WIDTH:cmos_width;
		else
			cmos_width_r <= cmos_width_r;

	always @ (posedge clk)
		if(!rst_n)
			laser_freq_r <= 0;
		else if(load_param_p)
			laser_freq_r <= laser_freq_ovf?MAX_LASER_FREQ:(laser_freq-10);
		else
			laser_freq_r <= laser_freq_r;

	always @ (posedge clk)
		if(!rst_n)
			laser_width_r <= 0;
		else if(load_param_p)
			laser_width_r <= laser_width_ovf?MAX_LASER_WIDTH:laser_width;
		else
			laser_width_r <= laser_width_r;

	always @ (posedge clk)
		if(!rst_n)
			frame_gate_width_a_r <= 0;
		else if(load_param_p)
			frame_gate_width_a_r <= frame_gate_width_a_ovf?MAX_FRAME_GATE_WIDTH_A:frame_gate_width_a;
		else
			frame_gate_width_a_r <= frame_gate_width_a_r;

	always @ (posedge clk)
		if(!rst_n)
			frame_gate_delay_a_r <= 0;
		else if(load_param_p)
			frame_gate_delay_a_r <= frame_gate_delay_a_ovf?MAX_FRAME_GATE_DELAY_A:frame_gate_delay_a;
		else
			frame_gate_delay_a_r <= frame_gate_delay_a_r;

	always @ (posedge clk)
		if(!rst_n)
			frame_gate_width_b_r <= 0;
		else if(load_param_p)
			frame_gate_width_b_r <= frame_gate_width_b_ovf?MAX_FRAME_GATE_WIDTH_B:frame_gate_width_b;
		else
			frame_gate_width_b_r <= frame_gate_width_b_r;

	always @ (posedge clk)
		if(!rst_n)
			frame_gate_delay_b_r <= 0;
		else if(load_param_p)
			frame_gate_delay_b_r <= frame_gate_delay_b_ovf?MAX_FRAME_GATE_DELAY_B:frame_gate_delay_b;
		else
			frame_gate_delay_b_r <= frame_gate_delay_b_r;

	always @ (posedge clk)
		if(!rst_n)
			tim_cycles_m_r <= 0;
		else if(load_param_p)
			tim_cycles_m_r <= tim_cycles_m;
		else
			tim_cycles_m_r <= tim_cycles_m_r;

	always @ (posedge clk)
		if(!rst_n)
			delay_step_delta_t_r <= 0;
		else if(load_param_p)
			delay_step_delta_t_r <= delay_step_delta_t;
		else
			delay_step_delta_t_r <= delay_step_delta_t_r;

	always @ (posedge clk)
		if(!rst_n)
			bg_frame_deci_n_r <= 0;
		else if(load_param_p)
			bg_frame_deci_n_r <= bg_frame_deci_n;
		else
			bg_frame_deci_n_r <= bg_frame_deci_n_r;

	// output logic
	assign cmos_freq_o = cmos_freq_r;
	assign cmos_width_o = cmos_width_r;
	assign laser_freq_o = laser_freq_r;
	assign laser_width_o = laser_width_r;
	assign frame_gate_width_a_o = frame_gate_width_a_r;
	assign frame_gate_delay_a_o = frame_gate_delay_a_r;
	assign frame_gate_width_b_o = frame_gate_width_b_r;
	assign frame_gate_delay_b_o = frame_gate_delay_b_r;
	assign tim_cycles_m_o = tim_cycles_m_r;
	assign delay_step_delta_t_o = delay_step_delta_t_r;
	assign bg_frame_deci_n_o = bg_frame_deci_n_r;

endmodule
