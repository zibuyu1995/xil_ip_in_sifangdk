// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : gate_pulse_gen.v
// Create : 2019-10-16 14:53:10
// Revised: 2019-11-04 15:06:32
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module gate_pulse_gen(
		input clk,
		input rst_n,
		//
		input [31:0] laser_cnt_in,
		input [31:0] laser_freq,
		input [31:0] frame_gate_width_a,
		input [31:0] frame_gate_delay_a,
		input [31:0] frame_gate_width_b,
		input [31:0] frame_gate_delay_b,
		input [7:0] tim_cycles_m,
		input [7:0] delay_step_delta_t,
		input [ 1:0] frame_type,
		// 
		output [ 9:0] gate_data_out
    );

	localparam FRAME_BG = 2'b00;
	localparam FRAME_A = 2'b01;
	localparam FRAME_B = 2'b10;

	reg [1:0] frame_type_q;
	wire frame_change;

	wire laser_pulse_hit;

	reg [31:0] frame_gate_width;
	reg [31:0] frame_gate_delay;

	reg [7:0] cycle_m_cnt;

	reg [32:0] preadd_cmp_fall;

	reg [32:0] cmp_rise_r;

	wire [32:0] cmp_rise;
	wire [32:0] cmp_fall;

	wire [9:0] bit_q;
	reg [9:0] gate_data_out_r;

	wire is_bg_frame;

	genvar inst;

	always @ (posedge clk)
		if(!rst_n)
			frame_type_q <= 0;
		else
			frame_type_q <= frame_type;

	assign frame_change = (frame_type_q!=frame_type);

	always @ (*) 
		case(frame_type)
			FRAME_A : begin
				frame_gate_width = frame_gate_width_a;
				frame_gate_delay = frame_gate_delay_a;
			end

			FRAME_B : begin
				frame_gate_width = frame_gate_width_b;
				frame_gate_delay = frame_gate_delay_b;
			end

			default : begin
				frame_gate_width = 0;
				frame_gate_delay = 0;
			end
		endcase

	assign laser_pulse_hit = (laser_cnt_in>=laser_freq);

	always @ (posedge clk)
		if(!rst_n | frame_change)
			cycle_m_cnt <= 0;
		else if(laser_pulse_hit) begin
			if(cycle_m_cnt >= tim_cycles_m)
				cycle_m_cnt <= 0;
			else
				cycle_m_cnt <= cycle_m_cnt + 1;
		end
		else 
			cycle_m_cnt <= cycle_m_cnt;

	multadd #(
		.SIZEIN(16)
	) multadd_i0 (
		.clk   (clk),
		.ce    (1'b1),
		.rst   (~rst_n),
		.a     ({8'd0, cycle_m_cnt}),
		.b     ({8'd0, delay_step_delta_t}),
		.c     ({1'b0, frame_gate_delay}),
		.p_out (cmp_rise)
	);

	always @ (posedge clk)
		if(!rst_n)
			cmp_rise_r <= 0;
		else if(laser_pulse_hit)
			cmp_rise_r <= cmp_rise;
		else
			cmp_rise_r <= cmp_rise_r;

	always @ (posedge clk)
		if(!rst_n)
			preadd_cmp_fall <= 0;
		else if(laser_pulse_hit)
			preadd_cmp_fall <= cmp_rise + frame_gate_width;
		else
			preadd_cmp_fall <= preadd_cmp_fall;

	assign cmp_fall = preadd_cmp_fall;

	generate
		for(inst=0; inst<10; inst=inst+1) begin
			cnt_bit_select #(
				.CNT_WIDTH(32  ),
				.BIT_INDEX(inst)
			) cnt_bit_select_i (
				.clk        (clk             ),
				.rst_n      (rst_n           ),
				.cnt_in     (laser_cnt_in    ),
				.cmp_rise_in(cmp_rise_r[31:0]),
				.cmp_fall_in(cmp_fall[31:0]  ),
				.bit_q      (bit_q[inst]     )
			);
		end
	endgenerate

	assign is_bg_frame = (frame_type==FRAME_BG);

	always @ (posedge clk)
		if(!rst_n)
			gate_data_out_r <= 0;
		else
			gate_data_out_r <= (is_bg_frame==1'b1)?10'd0:bit_q;

	assign gate_data_out = gate_data_out_r;


endmodule
