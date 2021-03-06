// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : img_packet.v
// Create : 2019-11-14 14:28:30
// Revised: 2020-04-03 11:46:39
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module img_packet #(
		parameter LINE_SIZE  = 1024     ,
		parameter IMAGE_SIZE = 1024*1024,
		parameter PIX_SIZE = 8          ,
		parameter PKT_MODE = "2D"
	) (
		input         clk          , // Clock
		input         rst_n        , // Synchronous reset active low
		// stream_in
		input  [31:0] data_in      ,
		input         data_in_valid,
		// output fifo interface
		output [31:0] fifo_wrdata  ,
		output        fifo_wren    ,
		input         fifo_full    ,
		// misc
		input         wr2ddr_en    ,
		output        fifo_overflow,
		input         frame_start  ,
		input  [ 1:0] frame_type_i ,
		output        frame_store  ,
		output [ 1:0] frame_type_o
	);

	localparam PIX_PER_DATA = 32 / PIX_SIZE;
	localparam WR_NUM = IMAGE_SIZE / PIX_PER_DATA;
	localparam LINE_NUM = LINE_SIZE / PIX_PER_DATA;

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
	reg [1:0] frame_type_qq;
	wire frame_start_rise;
	reg [31:0] frame_cnt;

	wire [31:0] parity_w;
	wire [31:0] frame_info_dw0;
	wire [31:0] frame_info_dw1;
	wire [31:0] frame_info_dw2;
	wire [31:0] frame_info_dw3;

	reg [31:0] fifo_wrdata_r;
	reg fifo_wren_r;

	reg frame_store_r;

	reg fifo_overflow_r;

	reg wr2ddr_en_q;
	reg wr2ddr_en_r;
	wire wr2ddr_en_hit;

	reg [20:0] int_cnt;
	reg [2:0] mst_state;

	generate
		if(PKT_MODE=="2D") 
			assign frame_info_dw0 = {16'd0, {6'd0, frame_type_qq}, 8'd0}; // 31-16bit---reserved, 15-8bit---frame type, 7-0bit---0-2d, 1-3d
		else 
			assign frame_info_dw0 = {16'd0, {6'd0, frame_type_qq}, 8'd1}; // 31-16bit---reserved, 15-8bit---frame type, 7-0bit---0-2d, 1-3d
	endgenerate
	
	assign frame_info_dw1 = 32'd0;
	assign frame_info_dw2 = 32'd0;
	assign frame_info_dw3 = frame_cnt;

	parity_xor #(
		.DATA_WIDTH(32)
	) parity_xor_i0 (
		.clk       (clk),
		.rst_n     (rst_n||frame_start_rise),
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
			wr2ddr_en_q <= 0;
		end
		else begin
			data_in_q <= data_in;
			data_in_valid_q <= data_in_valid;
			frame_start_q <= frame_start;
			frame_type_q <= frame_type_i;
			wr2ddr_en_q <= wr2ddr_en;
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
						if(int_cnt>=WR_NUM-1)
							int_cnt <= 0;
						else
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

	always @ (posedge clk)
		if(!rst_n)
			frame_cnt <= 0;
		else if((mst_state==DONE)&&(wr2ddr_en_r==1'b1))
			frame_cnt <= frame_cnt + 1'b1;
		else
			frame_cnt <= frame_cnt;

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
					fifo_wren_r <= ({data_in_valid_q, wr2ddr_en_r}==2'b11);
				end

				PARITY : begin
					if((int_cnt==0)&&(fifo_full==1'b0))
						fifo_wrdata_r <= parity_w;
					else
						fifo_wrdata_r <= 0;
					fifo_wren_r <= ({fifo_full, wr2ddr_en_r}==2'b01);
				end

				FRAME_INFO : begin
					case(int_cnt)
						4 : fifo_wrdata_r <= frame_info_dw0;
						5 : fifo_wrdata_r <= frame_info_dw1;
						6 : fifo_wrdata_r <= frame_info_dw2;
						7 : fifo_wrdata_r <= frame_info_dw3;
						default : fifo_wrdata_r <= fifo_wrdata_r;
					endcase
					fifo_wren_r <= ({fifo_full, wr2ddr_en_r}==2'b01);
				end

				FLUSH : begin
					fifo_wrdata_r <= 0;
					fifo_wren_r <= ({fifo_full, wr2ddr_en_r}==2'b01);
				end

				default : begin
					fifo_wrdata_r <= 0;
					fifo_wren_r <= 0;
				end
			endcase

	always @ (posedge clk)
		if(!rst_n)
			frame_store_r <= 0;
		else if((mst_state==DONE)&&(wr2ddr_en_r==1'b1))
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
					if((int_cnt>=WR_NUM-1)&&(data_in_valid_q==1'b1))
						mst_state <= PARITY;
					else
						mst_state <= WR_DATA;

				PARITY :
					if((int_cnt>=3)&&(fifo_full==1'b0)) 
						mst_state <= FRAME_INFO;
					else
						mst_state <= PARITY;

				FRAME_INFO :
					if((int_cnt>=7)&&(fifo_full==1'b0))
						mst_state <= FLUSH;
					else
						mst_state <= FRAME_INFO;

				FLUSH : 
					if((int_cnt>=LINE_NUM-1)&&(fifo_full==1'b0))
						mst_state <= DONE;
					else
						mst_state <= FLUSH;

				DONE : 
					mst_state <= IDLE;

				default : 
					mst_state <= IDLE;
			endcase
	end

	// write to ddr enable control
	generate
		if(PKT_MODE=="2D") 
			assign wr2ddr_en_hit = ({frame_start_rise, frame_type_q, wr2ddr_en_q}==4'b1001);
		else 
			assign wr2ddr_en_hit = ({frame_start_rise, wr2ddr_en_q}==2'b11);
	endgenerate

	always @ (posedge clk)
		if(!rst_n)
			wr2ddr_en_r <= 0;
		else if(wr2ddr_en_q==1'b0)
			wr2ddr_en_r <= 0;
		else if(wr2ddr_en_hit)
			wr2ddr_en_r <= 1;
		else
			wr2ddr_en_r <= wr2ddr_en_r;

	// output logic
	assign fifo_wrdata = fifo_wrdata_r;
	assign fifo_wren = fifo_wren_r;
	assign fifo_overflow = fifo_overflow_r;
	assign frame_store = frame_store_r;
	assign frame_type_o = frame_type_qq;

endmodule