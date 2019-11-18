// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : img_deci.v
// Create : 2019-11-07 17:32:25
// Revised: 2019-11-07 17:53:22
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module img_deci(
		input clk,
		input rst_n,
		//
		input [63:0] din,
		input din_valid,
		//
		output [31:0] dout,
		output dout_valid,
		//
		input frame_start
    );

	localparam IMG_WIDTH = 2048;
	localparam IMG_HEIGHT = 2048;
	localparam IMG_SIZE = IMG_WIDTH*IMG_HEIGHT;
	localparam PIX_NUM = IMG_SIZE/8;
	localparam LINE_NUM = IMG_WIDTH/8;

	reg [8:0] pix_cnt;

	reg [63:0] din_q;
	reg din_valid_q;
	reg frame_start_q;

	wire [63:0] shift_out;
	wire shift_pix_hit;

	reg [8:0] adder_q00;
	reg [8:0] adder_q01;
	reg [8:0] adder_q02;
	reg [8:0] adder_q03;
	reg [8:0] adder_q10;
	reg [8:0] adder_q11;
	reg [8:0] adder_q12;
	reg [8:0] adder_q13;
	reg adder_valid;

	reg [9:0] pix_q0;
	reg [9:0] pix_q1;
	reg [9:0] pix_q2;
	reg [9:0] pix_q3;
	reg pix_valid;

	reg [31:0] dout_r;
	reg dout_valid_r;

	/// pipeline stage 1 input buffer
	always @ (posedge clk)
		if(!rst_n) begin
			din_q <= 0;
			din_valid_q <= 0;
			frame_start_q <= 0;
		end
		else begin
			din_q <= din;
			din_valid_q <= din_valid;
			frame_start_q <= frame_start;
		end


	/// pipeline stage 2 
	always @ (posedge clk)
		if(!rst_n|frame_start_q)
			pix_cnt <= 0;
		else if(din_valid_q)
			pix_cnt <= pix_cnt + 1;
		else
			pix_cnt <= pix_cnt;

	assign shift_pix_hit = (pix_cnt>=LINE_NUM);

	shift_reg_bus #(.clock_cycles(LINE_NUM), .data_width(64)) shift_reg_bus_i0 (
		.clk       (clk        ),
		.rst_n     (rst_n      ),
		.data_in   (din_q      ),
		.data_valid(din_valid_q),
		.data_out  (shift_out  )
	);

	// conv img
	always @ (posedge clk)
		if(!rst_n) begin
			adder_q00 <= 0;
			adder_q01 <= 0;
			adder_q02 <= 0;
			adder_q03 <= 0;
			adder_q10 <= 0;
			adder_q11 <= 0;
			adder_q12 <= 0;
			adder_q13 <= 0;
			adder_valid <= 0;
		end
		else if({shift_pix_hit, din_valid_q}==2'b11) begin
			adder_q00 <= shift_out[7:0] + shift_out[15:8];
			adder_q01 <= shift_out[23:16] + shift_out[31:24];
			adder_q02 <= shift_out[39:32] + shift_out[47:40];
			adder_q03 <= shift_out[55:48] + shift_out[63:56];
			adder_q10 <= din_q[7:0] + din_q[15:8];
			adder_q11 <= din_q[23:16] + din_q[31:24];
			adder_q12 <= din_q[39:32] + din_q[47:40];
			adder_q13 <= din_q[55:48] + din_q[63:56];
			adder_valid <= 1;
		end
		else begin
			adder_q00 <= adder_q00;
			adder_q01 <= adder_q01;
			adder_q02 <= adder_q02;
			adder_q03 <= adder_q03;
			adder_q10 <= adder_q10;
			adder_q11 <= adder_q11;
			adder_q12 <= adder_q12;
			adder_q13 <= adder_q13;
			adder_valid <= 0;
		end

	always @ (posedge clk)
		if(!rst_n) begin
			pix_q0 <= 0;
			pix_q1 <= 0;
			pix_q2 <= 0;
			pix_q3 <= 0;
			pix_valid <= 0;
		end
		else if(adder_valid) begin
			pix_q0 <= adder_q00 + adder_q10;
			pix_q1 <= adder_q01 + adder_q11;
			pix_q2 <= adder_q02 + adder_q12;
			pix_q3 <= adder_q03 + adder_q13;
			pix_valid <= 1;
		end
		else begin
			pix_q0 <= pix_q0;
			pix_q1 <= pix_q1;
			pix_q2 <= pix_q2;
			pix_q3 <= pix_q3;
			pix_valid <= 0;
		end

	always @ (posedge clk)
		if(!rst_n) begin
			dout_r <= 0;
			dout_valid_r <= 0;
		end
		else if(pix_valid) begin
			dout_r <= {pix_q3[9:2], pix_q2[9:2], pix_q1[9:2], pix_q0[9:2]};
			dout_valid_r <= 1;
		end
		else begin
			dout_r <= 0;
			dout_valid_r <= 0;
		end

	// output logic
	assign dout = dout_r;
	assign dout_valid = dout_valid_r;

endmodule
