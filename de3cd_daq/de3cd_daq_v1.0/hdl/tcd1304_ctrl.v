// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : tcd1304_ctrl.v
// Create : 2019-07-05 14:29:56
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module tcd1304_ctrl(
		input clk,
		input rst_n,
		// tcd1304 interface
		output tcd1304_phi_m,
		output tcd1304_sh,			// tint range -- 10us ~ 6,553,510us, step 100us
		output tcd1304_icg,
		// parameter config
		input [15:0] tint_var,
		input tint_load,
		// misc ports
		input clk2m
    );

	localparam TINT_LOW_FRONT = 10; // 5000ns
	localparam TINT_BASE = 6; // 3000ns 
	localparam TINT_LOW_END = 1; // 500ns
	localparam TINT_HIGH = 3;

	localparam READOUT_BASE = 3694*4; // (32 dummy front + 3648 signal output + 14 dummy end)*(1/4 phi_m period)
	localparam ICG_LOW_BASE = 14; // 7000ns
	localparam ICG_TOTAL_NUM = READOUT_BASE + ICG_LOW_BASE;

	reg clk2m_r = 0;
	wire clk2m_rise_edge;

	(* use_dsp48="yes" *)reg [31:0] tint_var_w = 0;
	reg [31:0] tint_var_r = 0;
	reg [31:0] tint_cnt = 0;
	wire [31:0] tint_low_num;
	wire [31:0] tint_total_num;
	reg tcd1304_sh_r = 0;

	reg tcd1304_icg_r = 0;
	reg [31:0] readout_cnt = 0;
	wire [31:0] readout_start_num;

	// clock 2m rising edge detect
	always @ (posedge clk)
		if(!rst_n)
			clk2m_r <= 0;
		else
			clk2m_r <= clk2m;

	assign clk2m_rise_edge = ({clk2m_r, clk2m}==2'b01);

	// tint value load
	always @ (posedge clk)
		if(!rst_n)
			tint_var_w <= 0;
		else  	
			tint_var_w <= tint_var * 200;

	always @ (posedge clk)
		if(!rst_n)
			tint_var_r <= 0;
		else if(tint_load)
			tint_var_r <= tint_var_w;
		else
			tint_var_r <= tint_var_r;

	// sh signal generator
	assign tint_low_num = TINT_LOW_FRONT + TINT_LOW_END + TINT_BASE + tint_var_r - 1;
	assign tint_total_num = TINT_LOW_FRONT + TINT_LOW_END + TINT_BASE  + TINT_HIGH + tint_var_r - 1;

	always @ (posedge clk)
		if(!rst_n)
			tint_cnt <= 0;
		else if(clk2m_rise_edge) begin
			if(tint_cnt>=tint_total_num)
				tint_cnt <= 0;
			else
				tint_cnt <= tint_cnt + 1'b1;
		end
		else
			tint_cnt <= tint_cnt;

	always @ (posedge clk)
		if(!rst_n)
			tcd1304_sh_r <= 0;
		else if(clk2m_rise_edge) begin
			if(tint_cnt<=tint_low_num)
				tcd1304_sh_r <= 0;
			else
				tcd1304_sh_r <= 1;
		end
		else
			tcd1304_sh_r <= tcd1304_sh_r;

	// icg signal generator
	assign readout_start_num = TINT_LOW_FRONT + tint_var_r - 1;

	always @ (posedge clk)
		if(!rst_n)
			readout_cnt <= 0;
		else if(clk2m_rise_edge) begin
			if(readout_cnt==ICG_TOTAL_NUM-1)
				if(tint_cnt>=readout_start_num)
					readout_cnt <= 0;
				else
					readout_cnt <= readout_cnt;
			else
				readout_cnt <= readout_cnt + 1'b1;
		end
		else 
			readout_cnt <= readout_cnt;

	always @ (posedge clk)
		if(!rst_n)
			tcd1304_icg_r <= 0;
		else if(clk2m_rise_edge) begin
			if(readout_cnt==ICG_LOW_BASE)
				tcd1304_icg_r <= 1;
			else if(readout_cnt==0)
				tcd1304_icg_r <= 0;
			else
				tcd1304_icg_r <= tcd1304_icg_r;
		end
		else
			tcd1304_icg_r <= tcd1304_icg_r;

	// assign ports
	assign tcd1304_icg = tcd1304_icg_r;
	assign tcd1304_sh = tcd1304_sh_r;
	assign tcd1304_phi_m = clk2m;

endmodule
