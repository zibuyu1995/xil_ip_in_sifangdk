// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : if_convert.v
// Create : 2019-11-06 17:27:58
// Revised: 2019-11-07 15:34:50
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module if_convert (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	// input axi-stream
	input [63:0] s_axis_cmlk_tdata,
	input s_axis_cmlk_tlast,
	output s_axis_cmlk_tready,
	input s_axis_cmlk_tuser,
	input s_axis_cmlk_tvalid,
	// output local-stream
	output [63:0] dout,
	output dout_vld,
	// misc
	input [1:0] frame_type_i,
	output frame_start,
	output [1:0] frame_type_o,
	output unexpected_data,
	output unexpected_tlast
);

	localparam IMG_SIZE = 2048*2048;
	localparam PIX_NUM = IMG_SIZE/8;

	// stage 1 reg
	reg [63:0] tdata_q;
	reg tvalid_q;
	reg tlast_q;
	reg tuser_q;

	// stage 2 reg
	reg [63:0] tdata_qq;
	reg tvalid_qq;
	reg tlast_qq;
	reg tuser_qq;

	reg [19:0] pix_cnt;
	reg frame_start_r;
	reg [1:0] frame_type_r;

	wire frame_start_hit;
	wire unexpected_data_hit;
	wire unexpected_tlast_hit;

	// stage 3 reg
	reg [63:0] tdata_qqq;
	reg tvalid_qqq;

	reg unexpected_data_r;
	reg unexpected_tlast_r;


	// pipeline stage 1 -- buffer input
	always @ (posedge clk)
		if(!rst_n) begin
			tdata_q <= 0;
			tvalid_q <= 0;
			tlast_q <= 0;
			tuser_q <= 0;
		end
		else begin
			tdata_q <= s_axis_cmlk_tdata;
			tvalid_q <= s_axis_cmlk_tvalid;
			tlast_q <= s_axis_cmlk_tlast;
			tuser_q <= s_axis_cmlk_tuser;
		end

	assign frame_start_hit = ({tuser_q, tuser_qq, tvalid_q}==3'b101);

	// pipeline stage 2 -- detect frame start, assert expect data & store frame type
	always @ (posedge clk)
		if(!rst_n) begin
			tdata_qq <= 0;
			tvalid_qq <= 0;
			tlast_qq <= 0;
			tuser_qq <= 0;
		end
		else if(tvalid_q) begin
			tdata_qq <= tdata_q;
			tvalid_qq <= 1;
			tlast_qq <= tlast_q;
			tuser_qq <= tuser_q;
		end
		else begin
			tdata_qq <= tdata_qq;
			tvalid_qq <= 0;
			tlast_qq <= tlast_qq;
			tuser_qq <= tuser_qq;
		end

	always @ (posedge clk)
		if(!rst_n) begin
			frame_start_r <= 0;
			frame_type_r <= 0;
		end
		else if(frame_start_hit) begin
			frame_start_r <= 1;
			frame_type_r <= frame_type_i;
		end
		else begin
			frame_start_r <= 0;
			frame_type_r <= frame_type_r;
		end

	always @ (posedge clk)
		if(!rst_n|frame_start_hit) 
			pix_cnt <= 0;
		else if(tvalid_qq)
			pix_cnt <= pix_cnt + 1;
		else
			pix_cnt <= pix_cnt;

	assign unexpected_data_hit = (pix_cnt>=PIX_NUM-1)&&(tvalid_qq==1'b1);
	assign unexpected_tlast_hit = (pix_cnt==PIX_NUM-2)&&(tvalid_qq==1'b1)&&(tlast_qq==1'b0);

	// pipeline stage 3
	always @ (posedge clk)
		if(!rst_n)
			unexpected_data_r <= 0;
		else if(unexpected_data_hit)
			unexpected_data_r <= 1;
		else
			unexpected_data_r <= 0;
	
	always @ (posedge clk)
		if(!rst_n)
			unexpected_tlast_r <= 0;
		else if(unexpected_tlast_hit)
			unexpected_tlast_r <= 1;
		else
			unexpected_tlast_r <= 0;

	always @ (posedge clk)
		if(!rst_n) begin
			tdata_qqq <= 0;
			tvalid_qqq <= 0;
		end
		else begin
			tdata_qqq <= tdata_qq;
			tvalid_qqq <= tvalid_qq;
		end

	// output logic
	assign s_axis_cmlk_tready = 1'b1;

	assign dout = tdata_qqq;
	assign dout_vld = tvalid_qqq;
	assign frame_start = frame_start_r;
	assign frame_type_o = frame_type_r;
	assign unexpected_data = unexpected_data_r;
	assign unexpected_tlast = unexpected_tlast_r;

endmodule