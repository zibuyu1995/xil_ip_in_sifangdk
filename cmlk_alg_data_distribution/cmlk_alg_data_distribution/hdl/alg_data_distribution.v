// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : alg_data_distribution.v
// Create : 2019-10-22 16:28:45
// Revised: 2020-03-16 15:29:24
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module alg_data_distribution#(
		parameter CACHE_WIDTH = 29,
		parameter IMG_STRIDE = 1024*1025,
		parameter LINE_STRIDE = 1024,
		parameter NUM_LINE = 1024
	)(
		//
		input clk,
		input rst_n,
		// control interface
		input [31:0] base_addr,
		input load_addr,
		input frame_store,
		input [1:0] frame_type,
		// datamover ctrl a
		output [71:0] m0_axis_mm2s_cmd_tdata,
		input m0_axis_mm2s_cmd_tready,
		output m0_axis_mm2s_cmd_tvalid,
		// datamover ctrl b
		output [71:0] m1_axis_mm2s_cmd_tdata,
		input m1_axis_mm2s_cmd_tready,
		output m1_axis_mm2s_cmd_tvalid,
		// misc 
		output frame_store_o,
		output [1:0] frame_type_o,
		output lost_read
    );

	localparam OFFSET_WIDTH = CACHE_WIDTH-1;

    localparam IDLE = 3'b000;
    localparam RD_LINE_A = 3'b001;
    localparam RD_LINE_B = 3'b010;
    localparam RD_LINE_DONE = 3'b011;
    localparam RD_FRAME_DONE = 3'b100;

    wire [22:0] read_byte_num;

    reg [31:0] base_addr_r;
    reg [31:0] offset_addr_r;
	reg [31:0] offset_addr_r0;
	reg [31:0] offset_addr_r1;
	wire load_addr_p;
	wire frame_store_p;
	wire line_inc;
	wire img_inc;

	reg addr_init;
	wire is_idle;
	wire frame_read_done;
	wire line_read_done;
	wire is_bgframe;

	wire [31:0] offset_addr_r0_line_inc;
	wire [31:0] offset_addr_r1_line_inc;
	wire [31:0] offset_addr_r0_img_inc;
	wire [31:0] offset_addr_r1_img_inc;
	wire [31:0] offset_addr_r0_clr_inc;
	wire [31:0] offset_addr_r1_clr_inc;

	reg frame_inc;
	reg frame_clr;
	reg frame_clr_q;

	reg [9:0] frame_cnt;
	reg [11:0] rd_line_cnt;
	reg [2:0] mst_state;

	reg [1:0] frame_type_r;

	reg [5:0] frame_store_shift_r;
	reg frame_store_hit;

	reg lost_read_r;

	reg init_flag;

	alg_edge_detect alg_edge_detect_i0 (.rst_n(rst_n), .clk(clk), .sig(load_addr), .rise(load_addr_p), .fall());
	alg_edge_detect alg_edge_detect_i1 (.rst_n(rst_n), .clk(clk), .sig(frame_store), .rise(frame_store_p), .fall());

	assign offset_addr_r0_line_inc = offset_addr_r0 + LINE_STRIDE;
	assign offset_addr_r1_line_inc = offset_addr_r1 + LINE_STRIDE;
	assign offset_addr_r0_img_inc = offset_addr_r0 + IMG_STRIDE + LINE_STRIDE;
	assign offset_addr_r1_img_inc = offset_addr_r1 + IMG_STRIDE + LINE_STRIDE;
	assign offset_addr_r0_clr_inc = offset_addr_r;
	assign offset_addr_r1_clr_inc = offset_addr_r + IMG_STRIDE;
	assign frame_read_done = (mst_state==RD_FRAME_DONE);
	assign line_read_done = (mst_state==RD_LINE_DONE);
	assign is_idle = (mst_state==IDLE);
	assign is_bgframe = (frame_type==2'b00);
	assign read_byte_num = LINE_STRIDE;

	always @ (posedge clk)
		if(!rst_n||load_addr_p)
			init_flag <= 0;
		else if(frame_store_p)
			init_flag <= 1;
		else
			init_flag <= init_flag;

	always @ (posedge clk)
		if(!rst_n)
			frame_type_r <= 0;
		else if(frame_store_p)
			frame_type_r <= frame_type;
		else
			frame_type_r <= frame_type_r;


	always @ (posedge clk)
		if((!rst_n)||(~init_flag)) begin
			frame_inc <= 0;
			frame_clr <= 0;
		end
		else if(frame_store_p)
			if(is_bgframe) begin
				frame_inc <= 1'b0;
				frame_clr <= 1'b1;
			end
			else begin
				frame_inc <= 1'b1;
				frame_clr <= 1'b0;
			end
		else begin
			frame_inc <= 0;
			frame_clr <= 0;
		end

	always @ (posedge clk)
		if(!rst_n)
			frame_clr_q <= 0;
		else if(frame_clr)
			frame_clr_q <= 1;
		else if(frame_read_done|is_idle)
			frame_clr_q <= 0;
		else
			frame_clr_q <= frame_clr_q;

	always @ (posedge clk)
		if(!rst_n||frame_clr||load_addr_p)
			frame_cnt <= 0;
		else if(frame_inc)
			frame_cnt <= frame_cnt + 1'b1;
		else if(frame_read_done)
			frame_cnt <= frame_cnt - 1'b1;
		else
			frame_cnt <= frame_cnt;

	always @ (posedge clk)
		if(!rst_n||frame_read_done)
			rd_line_cnt <= 0;
		else if(line_read_done)
			rd_line_cnt <= rd_line_cnt + 1'b1;
		else
			rd_line_cnt <= rd_line_cnt;

	// address generator
	always @ (posedge clk)
		if(!rst_n)
			addr_init <= 0;
		else
			addr_init <= load_addr_p;

	always @ (posedge clk)
		if(!rst_n) 
			base_addr_r <= 0;
		else if(load_addr_p)
			base_addr_r <= base_addr;
		else
			base_addr_r <= base_addr_r;

	always @ (posedge clk)
		if(!rst_n)
			offset_addr_r <= 0;
		else if(addr_init)
			offset_addr_r <= base_addr_r + IMG_STRIDE*3;
		else 
			case(mst_state)
				IDLE : begin
					if(frame_clr==1'b1)
						offset_addr_r <= offset_addr_r - IMG_STRIDE;
					else if(frame_clr_q==1'b1)
						offset_addr_r <= offset_addr_r + IMG_STRIDE*3;
					else
						offset_addr_r <= offset_addr_r;
				end
				RD_FRAME_DONE : begin
					if(frame_clr_q==1'b1)
						offset_addr_r <= offset_addr_r + IMG_STRIDE*3;
					else
						offset_addr_r <= offset_addr_r + IMG_STRIDE;
				end
				default : offset_addr_r <= offset_addr_r;
			endcase
		

	always @ (posedge clk)
		if(!rst_n) begin
			offset_addr_r0 <= 0;
			offset_addr_r1 <= 0;
		end
		else if(addr_init) begin
			offset_addr_r0 <= base_addr_r;
			offset_addr_r1 <= base_addr_r + IMG_STRIDE;
		end
		else 
			case(mst_state)
				IDLE : begin
					offset_addr_r0 <= (frame_clr_q==1'b1)?offset_addr_r0_clr_inc:offset_addr_r0;
					offset_addr_r1 <= (frame_clr_q==1'b1)?offset_addr_r1_clr_inc:offset_addr_r1;
				end
				RD_LINE_DONE : begin
					offset_addr_r0 <= offset_addr_r0_line_inc;
					offset_addr_r1 <= offset_addr_r1_line_inc;
				end
				RD_FRAME_DONE : begin
					offset_addr_r0 <= (frame_clr_q==1'b1)?offset_addr_r0_clr_inc:offset_addr_r0_line_inc;
					offset_addr_r1 <= (frame_clr_q==1'b1)?offset_addr_r1_clr_inc:offset_addr_r1_line_inc;
				end
				default : begin
					offset_addr_r0 <= offset_addr_r0;
					offset_addr_r1 <= offset_addr_r1;
				end
			endcase

	// master state machine
	always @ (posedge clk)
		if(!rst_n)
			mst_state <= IDLE;
		else
			case (mst_state)
				IDLE : 
					if(frame_cnt>=2)
						mst_state <= RD_LINE_A;
					else
						mst_state <= IDLE;
				RD_LINE_A : 
					if({m0_axis_mm2s_cmd_tready, m0_axis_mm2s_cmd_tvalid}==2'b11)
						mst_state <= RD_LINE_B;
					else
						mst_state <= RD_LINE_A;

				RD_LINE_B : 
					if({m1_axis_mm2s_cmd_tready, m1_axis_mm2s_cmd_tvalid}==2'b11)
						mst_state <= RD_LINE_DONE;
					else
						mst_state <= RD_LINE_B;

				RD_LINE_DONE : 
					if(rd_line_cnt>=NUM_LINE-1)
						mst_state <= RD_FRAME_DONE;
					else
						mst_state <= RD_LINE_A;

				RD_FRAME_DONE : 
					mst_state <= IDLE;

				default : 
					mst_state <= IDLE;
			endcase

	// misc
	always @ (posedge clk)
		if(!rst_n)
			lost_read_r <= 0;
		else if((frame_cnt>=2)&&(frame_clr==1'b1))
			lost_read_r <= 1;
		else
			lost_read_r <= lost_read_r;

	always @ (posedge clk)
		if(!rst_n) begin
			frame_store_shift_r <= 0;
			frame_store_hit <= 0;
		end
		else begin
			if((mst_state==IDLE)&&(frame_cnt>=2)) 
				frame_store_shift_r <= {frame_store_shift_r[4:0], 1'b1};
			else
				frame_store_shift_r <= {frame_store_shift_r[4:0], 1'b0};
			frame_store_hit <= |frame_store_shift_r;
		end

	// output logic
	assign frame_store_o = frame_store_hit;
	assign frame_type_o = frame_type_r;
	assign lost_read = lost_read_r;
	assign m0_axis_mm2s_cmd_tvalid = (mst_state==RD_LINE_A);
	assign m0_axis_mm2s_cmd_tdata = {8'd0, base_addr_r[31:CACHE_WIDTH], offset_addr_r0[OFFSET_WIDTH:0], 1'b0, 1'b1, 6'd0, 1'b1, read_byte_num};
	assign m1_axis_mm2s_cmd_tvalid = (mst_state==RD_LINE_B);
	assign m1_axis_mm2s_cmd_tdata = {8'd0, base_addr_r[31:CACHE_WIDTH], offset_addr_r1[OFFSET_WIDTH:0], 1'b0, 1'b1, 6'd0, 1'b1, read_byte_num};

endmodule
