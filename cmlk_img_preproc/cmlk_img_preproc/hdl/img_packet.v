// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : img_packet.v
// Create : 2019-11-14 14:28:30
// Revised: 2019-11-15 17:37:50
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module img_packet (
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low
	// stream_in
	input [31:0] data_in,
	input data_in_valid,
	// output fifo interface
	output [31:0] fifo_wrdata,
	output fifo_wren,
	input fifo_full,
	// misc
	output fifo_overflow,
	input frame_start,
	input [1:0] frame_type_i,
	output frame_store,
	output [1:0] frame_type_o
);
	localparam LINE_SIZE = 1024;
	localparam IMAGE_SIZE = 1024*1024;
	localparam WR_NUM = IMAGE_SIZE/4;
	localparam LINE_NUM = LINE_SIZE/4;

	localparam IDLE = 3'd0;
	localparam WR_DATA = 3'd1;
	localparam PARITY = 3'd2;  // INDEX(32bit): 0---CMLK->DDR, 1---DDR->EMMC, 2---EMMC->NET, 3---RESERVED
	localparam FRAME_INFO = 3'd3;
	localparam FLUSH = 3'd4;
	localparam DONE = 3'd5;

	reg [31:0] data_in_q;
	reg data_in_valid_q;
	reg frame_start_q;
	reg [1:0] frame_type_q;

	reg frame_start_qq;
	reg frame_type_qq;
	wire frame_start_rise;

	wire [31:0] parity_w;
	wire [31:0] frame_info_dw0;
	wire [31:0] frame_info_dw1;
	wire [31:0] frame_info_dw2;

	reg [31:0] fifo_wrdata_r;
	reg fifo_wren_r;

	reg frame_store_r;

	reg fifo_overflow_r;

	reg [17:0] int_cnt;
	reg [2:0] mst_state;

	assign frame_info_dw0 = {16'd0, {6'd0, frame_type_qq}, 8'd0}; // 31-16bit---reserved, 15-8bit---frame type, 7-0bit---0-2d, 1-3d
	assign frame_info_dw1 = 32'd0;
	assign frame_info_dw2 = 32'd0;

	parity_xor #(
		.DATA_WIDTH(32)
	) parity_xor_i0 (
		.clk       (clk),
		.rst_n     (rst_n),
		.data_in   (data_in_q),
		.parity_en (data_in_valid_q),
		.data_out  (parity_w)
	);


	// input buffer
	always @ (posedge clk)
		if(!rst_n) begin
			data_in_q <= 0;
			data_in_valid_q <= 0;
			frame_start_q <= 0;
			frame_type_q <= 0;
		end
		else begin
			data_in_q <= data_in;
			data_in_valid_q <= data_in_valid;
			frame_start_q <= frame_start;
			frame_type_q <= frame_type_i;
		end

	// detect frame start & save frame type
	always @ (posedge clk)
		if(!rst_n) 
			frame_start_qq <= 0;
		else
			frame_start_qq <= frame_start_q;

	assign frame_start_rise = ({frame_start_qq, frame_start_q}==2'b01);

	always @ (posedge clk)
		if(!rst_n)
			frame_type_qq <= 0;
		else if(frame_start_rise)
			frame_type_qq <= frame_type_q;
		else
			frame_type_qq <= frame_type_qq;

	// internal counter
	always @ (posedge clk)
		if(!rst_n)
			int_cnt <= 0;
		else
			case (mst_state)
				WR_DATA : 
					if(data_in_valid_q)
						int_cnt <= int_cnt + 1;
					else
						int_cnt <= int_cnt;

				PARITY, FRAME_INFO, FLUSH : 
					if(fifo_full==1'b0)
						int_cnt <= int_cnt + 1;
					else
						int_cnt <= int_cnt;
				default : int_cnt <= 0;
			endcase

	// write fifo buffer
	always @ (posedge clk)
		if(!rst_n) begin
			fifo_wrdata_r <= 0;
			fifo_wren_r <= 0;
		end
		else 
			case (mst_state)
				WR_DATA : begin
					fifo_wrdata_r <= data_in_q;
					fifo_wren_r <= data_in_valid_q;
				end

				PARITY : begin
					if((int_cnt==0)&&(fifo_full==1'b0))
						fifo_wrdata_r <= parity_w;
					else
						fifo_wrdata_r <= 0;
					fifo_wren_r <= (fifo_full==1'b0);
				end

				FRAME_INFO : begin
					if((int_cnt==4)&&(fifo_full==1'b0))
						fifo_wrdata_r <= frame_info_dw0;
					else if((int_cnt==5)&&(fifo_full==1'b0))
						fifo_wrdata_r <= frame_info_dw1;
					else if((int_cnt==6)&&(fifo_full==1'b0))
						fifo_wrdata_r <= frame_info_dw2;
					else
						fifo_wrdata_r <= fifo_wrdata_r;
					fifo_wren_r <= (fifo_full==1'b0);
				end

				FLUSH : begin
					fifo_wrdata_r <= 0;
					fifo_wren_r <= (fifo_full==1'b0);
				end

				default : begin
					fifo_wrdata_r <= 0;
					fifo_wren_r <= 0;
				end
			endcase

	always @ (posedge clk)
		if(!rst_n)
			frame_store_r <= 0;
		else if(mst_state==DONE)
			frame_store_r <= 1;
		else
			frame_store_r <= 0;

	// fifo overflow flag
	always @ (posedge clk)
		if(!rst_n)
			fifo_overflow_r <= 0;
		else if((data_in_valid_q==1'b1)&&(fifo_full==1'b1))
			fifo_overflow_r <= 1;
		else
			fifo_overflow_r <= fifo_overflow_r;

	// main state machine
	always @ (posedge clk) begin : proc_mst_state
		if(!rst_n) 
			mst_state <= 0;
		else 
			case (mst_state)
				IDLE : 
					if(frame_start_rise)
						mst_state <= WR_DATA;
					else
						mst_state <= IDLE;

				WR_DATA : 
					if(int_cnt>=WR_NUM-1)
						mst_state <= PARITY;
					else
						mst_state <= WR_DATA;

				PARITY :
					if(int_cnt>=3) 
						mst_state <= FRAME_INFO;
					else
						mst_state <= PARITY;

				FRAME_INFO :
					if(int_cnt>=6)
						mst_state <= FLUSH;
					else
						mst_state <= FRAME_INFO;

				FLUSH : 
					if(int_cnt>=LINE_NUM-1)
						mst_state <= DONE;
					else
						mst_state <= FLUSH;

				DONE : 
					mst_state <= IDLE;

				default : 
					mst_state <= IDLE;
			endcase
	end

	// output logic
	assign fifo_wrdata = fifo_wrdata_r;
	assign fifo_wren = fifo_wren_r;
	assign fifo_overflow = fifo_overflow_r;
	assign frame_store = frame_store_r;
	assign frame_type_o = frame_type_qq;

endmodule