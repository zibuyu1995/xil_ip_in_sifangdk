// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cnt_bit_select.v
// Create : 2019-10-15 17:19:48
// Revised: 2019-10-16 14:07:27
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cnt_bit_select #(
		parameter CNT_WIDTH = 32,
		parameter BIT_INDEX = 0
	)(
		input clk,
		input rst_n,
		//
		input [CNT_WIDTH-1:0] cnt_in,
		input [CNT_WIDTH-1:0] cmp_rise_in,
		input [CNT_WIDTH-1:0] cmp_fall_in,
		output bit_q
    );


	reg [CNT_WIDTH-1:0] cnt_added; // cnt + bit_index
	reg [CNT_WIDTH-1:0] cmp_rise_q; // 
	reg [CNT_WIDTH-1:0] cmp_fall_q; // 
	reg bit_q_r;

	// stage 1
	always @ (posedge clk)
		if(!rst_n)
			cnt_added <= 0;
		else
			cnt_added <= cnt_in + BIT_INDEX;

	always @ (posedge clk)
		if(!rst_n)
			cmp_rise_q <= 0;
		else
			cmp_rise_q <= cmp_rise_in;

	always @ (posedge clk)
		if(!rst_n)
			cmp_fall_q <= 0;
		else
			cmp_fall_q <= cmp_fall_in;

	// stage 2
	always @ (posedge clk)
		if(!rst_n)
			bit_q_r <= 0;
		else if(cnt_added < cmp_rise_q) 
			bit_q_r <= 0;
		else if(cnt_added < cmp_fall_q)
			bit_q_r <= 1;
		else
			bit_q_r <= 0;

	// output logic
	assign bit_q = bit_q_r;


endmodule
