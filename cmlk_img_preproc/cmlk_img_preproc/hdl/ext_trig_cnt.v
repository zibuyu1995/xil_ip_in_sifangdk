// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : ext_trig_cnt.v
// Create : 2019-11-20 15:48:24
// Revised: 2019-11-20 15:59:53
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module ext_trig_cnt (
	input  clk              , // Clock
	input  rst_n            , // Synchronous reset active low
	input  en_cnt           ,
	input  ext_trig         ,
	input  frame_start      ,
	output ext_trig_overflow
);

	reg en_cnt_q;

	reg ext_trig_q;
	reg ext_trig_qq;
	wire ext_trig_rise;

	reg frame_start_q;
	reg frame_start_qq;
	wire frame_start_rise;

	reg [15:0] int_cnt;

	reg ext_trig_overflow_r;

	// input buffer
	always @ (posedge clk)
		if(!rst_n) begin
			ext_trig_q <= 0;
			frame_start_q <= 0;
			en_cnt_q <= 0;
		end
		else begin
			ext_trig_q <= ext_trig;
			frame_start_q <= frame_start;
			en_cnt_q <= en_cnt;
		end

	// detect frame start & ext_trig
	always @ (posedge clk)
		if(!rst_n) 
			ext_trig_qq <= 0;
		else
			ext_trig_qq <= ext_trig_q;

	assign ext_trig_rise = ({ext_trig_qq, ext_trig_q}==2'b01);

	always @ (posedge clk)
		if(!rst_n) 
			frame_start_qq <= 0;
		else
			frame_start_qq <= frame_start_q;

	assign frame_start_rise = ({frame_start_qq, frame_start_q}==2'b01);

	always @ (posedge clk)
		if(!rst_n)
			int_cnt <= 0;
		else if(en_cnt_q)
			case({ext_trig_rise, frame_start_rise})
				2'b10 : int_cnt <= int_cnt + 1;
				2'b01 : int_cnt <= (int_cnt==0)?0:int_cnt - 1;
				default : int_cnt <= int_cnt;
			endcase // {ext_trig_rise, frame_start_rise}
		else
			int_cnt <= int_cnt;

	always @ (posedge clk)
		if(!rst_n)
			ext_trig_overflow_r <= 0;
		else if(int_cnt>1)
			ext_trig_overflow_r <= 1;
		else
			ext_trig_overflow_r <= ext_trig_overflow_r;

	// output logic
	assign ext_trig_overflow = ext_trig_overflow_r;


endmodule