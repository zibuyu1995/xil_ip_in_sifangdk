// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : conv_frame_to_addr.v
// Create : 2019-03-29 13:41:58
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module conv_frame_to_addr(clk, rst_n, frame, subframe, startframe, baseaddr);

	input clk, rst_n;    // Clock & Asynchronous reset active low
	input [15:0] frame, startframe;
	input [3:0] subframe;
	output [31:0] baseaddr;	// 3 clock latency full pipeline

	reg [15:0] frame_p1;
	reg [31:0] frame_p2;
	reg [31:0] frame_p3;
	wire [15:0] frame_p0 = {5'b00000, 1'b1, frame[9:0]};

	//calculate frame number stage 1
	always @ (posedge clk)
		if(!rst_n) 
			frame_p1 <= 0;
		else 
			frame_p1 <= frame_p0 - startframe;

	//mod and multipy 10 and add subframe number stage 2
	always @ (posedge clk)
		if(!rst_n)
			frame_p2 <= 0;
		else 
			frame_p2 <= (frame_p1[9:0]<<3) + (frame_p1[9:0]<<1) + subframe;

	//calculate baseaddr stage 3
	always @ (posedge clk)
		if(!rst_n)
			frame_p3 <= 0;
		else
			frame_p3 <= {2'd0, frame_p2, 15'd0};

	assign baseaddr = frame_p3;


endmodule