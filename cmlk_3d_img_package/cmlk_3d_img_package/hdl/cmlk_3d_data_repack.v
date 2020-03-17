// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_3d_data_repack.v
// Create : 2020-03-16 16:06:23
// Revised: 2020-03-16 16:13:54
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module cmlk_3d_data_repack (
		input clk,    // Clock
		input rst_n,  // Synchronous reset active low
		// input stream
		input [15:0] din,
		input din_vld,
		// output stream
		output [31:0] dout,
		output dout_vld
	);

	reg shift_flag;
	reg [31:0] dout_r;
	reg [1:0] dout_vld_r;

	always @ (posedge clk)
		if(!rst_n)
			dout_r <= 0;
		else if(din_vld)
			dout_r <= {dout_r[15:0], din};
		else
			dout_r <= dout_r;

	always @ (posedge clk)
		if(!rst_n)
			shift_flag <= 0;
		else if(din_vld)
			shift_flag <= ~shift_flag;
		else
			shift_flag <= shift_flag;

	always @ (posedge clk)
		if(!rst_n)
			dout_vld_r <= 0;
		else 
			dout_vld_r <= ({shift_flag, din_vld}==2'b11);

endmodule