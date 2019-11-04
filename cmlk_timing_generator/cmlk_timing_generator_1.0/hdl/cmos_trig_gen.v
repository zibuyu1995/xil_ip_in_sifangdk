// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmos_trig_gen.v
// Create : 2019-10-15 14:57:27
// Revised: 2019-11-04 13:50:50
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cmos_trig_gen(
		input clk,		// 100MHz
		input rst_n,
		//
		input [15:0] cmos_trig_period,
		input [15:0] cmos_trig_width,
		//
		output cmos_trig_pulse
    );

	//________________________________________________________
	// clogb2 function

	function integer clogb2 (input integer bit_depth);
		begin
			for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
				bit_depth = bit_depth >> 1;
		end
	endfunction 
 

	localparam CLOCK_PERIOD = 10;
	localparam REAL_1MS = 1000000;
	localparam CNT_1MS = REAL_1MS / CLOCK_PERIOD;

	localparam BASE_CNT_WIDTH = clogb2(CNT_1MS);

	reg [BASE_CNT_WIDTH-1:0] trig_base_cnt;
	reg [15:0] trig_1ms_cnt;

	reg [15:0] cmos_trig_period_r;
	reg [15:0] cmos_trig_width_r;

	wire trig_base_hit;
	wire trig_period_hit;
	wire trig_width_hit;
	wire pulse_disable;

	reg trig_pulse_r;

	// ports buffer
	always @ (posedge clk)
		if(!rst_n) begin
			cmos_trig_period_r <= 0;
			cmos_trig_width_r <= 0;
		end
		else begin
			cmos_trig_period_r <= cmos_trig_period;
			cmos_trig_width_r <= cmos_trig_width;
		end

	// base counter
	assign trig_base_hit = (trig_base_cnt==CNT_1MS-1);

	always @ (posedge clk)
		if(!rst_n) 
			trig_base_cnt <= 0;
		else if(trig_base_cnt>=CNT_1MS-1)
			trig_base_cnt <= 0;
		else
			trig_base_cnt <= trig_base_cnt + 1'b1; 


	// 1ms counter
	assign trig_period_hit = (trig_1ms_cnt==0);
	assign trig_width_hit = (trig_1ms_cnt==cmos_trig_width_r);
	assign pulse_disable = (cmos_trig_period_r==0);

	always @ (posedge clk)
		if(!rst_n)
			trig_1ms_cnt <= 0;
		else if(trig_base_hit) begin
			if(trig_1ms_cnt>=cmos_trig_period_r-1)
				trig_1ms_cnt <= 0;
			else
				trig_1ms_cnt <= trig_1ms_cnt + 1'b1;
		end
		else
			trig_1ms_cnt <= trig_1ms_cnt;

	// pulse generate
	always @ (posedge clk)
		if(!rst_n)
			trig_pulse_r <= 0;
		else if(trig_base_hit&&(pulse_disable==1'b0)) begin
			if(trig_period_hit)
				trig_pulse_r <= 1;
			else if(trig_width_hit)
				trig_pulse_r <= 0;
			else
				trig_pulse_r <= trig_pulse_r;
		end
		else 
			trig_pulse_r <= trig_pulse_r;

	// output logic
	assign cmos_trig_pulse = trig_pulse_r;

endmodule
