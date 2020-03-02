// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_clock_divider.v
// Create : 2019-11-21 15:42:18
// Revised: 2019-11-21 16:49:06
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_clock_divider(
		input clk,
		input rst_n,
		//
		input wire [15:0] divisor,	// the value is half-frequency
		//
		output sd_clk_div,
		output sd_clk_div_90,
		output locked
    );

	reg [15:0] divisor_q;
	reg [15:0] divisor_qq;
	wire freq_change;

	reg [15:0] div_cnt;

	reg [3:0] lock_cnt;
	reg [1:0] div_edge_r = 2'b00;
	wire div_pos_edge;

	reg sd_clk_div_r;
	reg sd_clk_div_90_r;
	reg locked_r;

	// input buffer
	always @ (posedge clk)
		if(!rst_n)
			divisor_q <= 0;
		else
			divisor_q <= divisor;

	// detect frequency change
	always @ (posedge clk)
		if(!rst_n)
			divisor_qq <= 0;
		else
			divisor_qq <= divisor_q;

	assign freq_change = (divisor_qq!=divisor_q);

	// div_cnt generator
	always @ (posedge clk)
		if(!rst_n)
			div_cnt <= 0;
		else if(div_cnt>=divisor_q)
			div_cnt <= 0;
		else
			div_cnt <= div_cnt + 1;

	// sd_clk_div generator
	always @ (posedge clk)
		if(!rst_n)
			sd_clk_div_r <= 0;
		else if(div_cnt=={1'b0, divisor_q[15:1]})
			sd_clk_div_r <= ~sd_clk_div_r;
		else
			sd_clk_div_r <= sd_clk_div_r;

	// sd_clk_div_90 generator
	always @ (posedge clk)
		if(!rst_n)
			sd_clk_div_90_r <= 0;
		else if(div_cnt==divisor_q)
			sd_clk_div_90_r <= ~sd_clk_div_90_r;
		else
			sd_clk_div_90_r <= sd_clk_div_90_r;

	// locked generator
	always @ (posedge clk)
		div_edge_r <= {div_edge_r[0], sd_clk_div_r};

	assign div_pos_edge = (div_edge_r==2'b01);

	always @ (posedge clk)
		if(!rst_n||freq_change)
			lock_cnt <= 0;
		else if(lock_cnt[3]==1'b1)
			lock_cnt <= lock_cnt;
		else if(div_pos_edge)
			lock_cnt <= lock_cnt + 1;
		else
			lock_cnt <= lock_cnt;

	always @ (posedge clk)
		if(!rst_n)
			locked_r <= 0;
		else
			locked_r <= lock_cnt[3];

	// output logic
	assign sd_clk_div = sd_clk_div_r;
	assign sd_clk_div_90 = sd_clk_div_90_r;
	assign locked = locked_r;


endmodule
