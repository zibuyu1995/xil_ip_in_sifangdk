// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : img_diff.v
// Create : 2019-11-13 09:30:51
// Revised: 2019-11-14 14:28:16
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module img_diff(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input diff_en, // diff mode enable
	// data path in
	input [31:0] data_in,
	input data_in_valid,
	// data path out
	output [31:0] data_out,
	output data_out_valid,
	// dual port ram interface
	output [17:0] waddr,
	output [31:0] wdata,
	output wvalid,
	output [17:0] raddr,
	input [31:0] rdata, 
	// misc
	input frame_start,
	input [1:0] frame_type
);

	localparam FRAME_BG = 2'b00;
	localparam FRAME_A = 2'b01;
	localparam FRAME_B = 2'b10;

	localparam IDLE = 2'd0;
	localparam STORE_FRAME = 2'd1;
	localparam READ_FRAME = 2'd2;
	localparam DONE = 2'd3;

	reg [31:0] data_in_q;
	reg data_in_valid_q;
	reg frame_start_q;
	reg [1:0] frame_type_q;
	reg diff_en_q;

	reg frame_start_qq;
	wire frame_start_rise;

	reg [17:0] waddr_r;
	reg [17:0] raddr_r;

	reg [31:0] wdata_r;
	reg wvalid_r;

	reg [31:0] rdata_qqqq;
	wire rvalid_pre; 			// pre 2 clock
	reg rvalid_qq;
	reg rvalid_qqq;
	reg rvalid_qqqq;

	reg [31:0] data_in_qq;		// pipeline stage 2
	reg [31:0] data_in_qqq;		// pipeline stage 3
	reg [31:0] data_in_qqqq;	// pipeline stage 4

	wire [31:0] diff_data;
	reg diff_data_valid;

	reg [31:0] diff_data_q;
	reg diff_data_valid_q;

	reg [31:0] data_out_r;
	reg data_out_valid_r;
	reg data_src_sel;			// 0---bypass 1---diff out

	reg [1:0] mst_state;

	// input buffer
	always @ (posedge clk)
		if(!rst_n) begin
			data_in_q <= 0;
			data_in_valid_q <= 0;
			frame_start_q <= 0;
			frame_type_q <= 0;
			diff_en_q <= 0;
		end
		else begin
			data_in_q <= data_in;
			data_in_valid_q <= data_in_valid;
			frame_start_q <= frame_start;
			frame_type_q <= frame_type;
			diff_en_q <= diff_en;
		end

	// detect frame start
	always @ (posedge clk)
		if(!rst_n) 
			frame_start_qq <= 0;
		else
			frame_start_qq <= frame_start_q;

	assign frame_start_rise = ({frame_start_qq, frame_start_q}==2'b01);

	// write ram ptr
	always @ (posedge clk)
		if(!rst_n) begin
			waddr_r <= 0;
			wdata_r <= 0;
			wvalid_r <= 0;
		end
		else
			case (mst_state)
				STORE_FRAME : begin
					if(data_in_valid_q) begin
						waddr_r <= waddr_r + 1;
						wdata_r <= data_in_q;
						wvalid_r <= 1;
					end
					else begin
						waddr_r <= waddr_r;
						wdata_r <= wdata;
						wvalid_r <= 0;
					end
				end
				default : begin
					waddr_r <= 0;
					wdata_r <= 0;
					wvalid_r <= 0;
				end
			endcase

	// read ram ptr
	always @ (posedge clk)
		if(!rst_n)
			raddr_r <= 0;
		else
			case(mst_state)
				READ_FRAME : 
					if(data_in_valid_q)
						raddr_r <= raddr_r + 1;
					else
						raddr_r <= raddr_r;
				default : raddr_r <= 0;
			endcase

	// ready ram data & align stream_in data
	assign rvalid_pre = (mst_state==READ_FRAME)&&data_in_valid_q;

	always @ (posedge clk)
		if(!rst_n) begin
			rdata_qqqq <= 0;
			rvalid_qq <= 0;
			rvalid_qqq <= 0;
			rvalid_qqqq <= 0;
		end
		else begin
			rdata_qqqq <= rdata;
			rvalid_qq <= rvalid_pre;
			rvalid_qqq <= rvalid_qq;
			rvalid_qqqq <= rvalid_qqq;
		end

	always @ (posedge clk)
		if(!rst_n) begin
			data_in_qq <= 0;
			data_in_qqq <= 0;
			data_in_qqqq <= 0;
		end
		else begin
			data_in_qq <= data_in_q;
			data_in_qqq <= data_in_qq;
			data_in_qqqq <= data_in_qqq;
		end

	// differential
	img_subtractor #(.WIDTH(8)) img_subtractor_i0 (.clk(clk), .rst_n(rst_n), .a(data_in_qqqq[7:0]), .b(rdata_qqqq[7:0]), .cout(diff_data[7:0]));
	img_subtractor #(.WIDTH(8)) img_subtractor_i1 (.clk(clk), .rst_n(rst_n), .a(data_in_qqqq[15:8]), .b(rdata_qqqq[15:8]), .cout(diff_data[15:8]));
	img_subtractor #(.WIDTH(8)) img_subtractor_i2 (.clk(clk), .rst_n(rst_n), .a(data_in_qqqq[23:16]), .b(rdata_qqqq[23:16]), .cout(diff_data[23:16]));
	img_subtractor #(.WIDTH(8)) img_subtractor_i3 (.clk(clk), .rst_n(rst_n), .a(data_in_qqqq[31:24]), .b(rdata_qqqq[31:24]), .cout(diff_data[31:24]));

	always @ (posedge clk)
		if(!rst_n)
			diff_data_valid <= 0;
		else
			diff_data_valid <= rvalid_qqqq;


	always @ (posedge clk)
		if(!rst_n) begin
			diff_data_q <= 0;
			diff_data_valid_q <= 0;
		end
		else begin
			diff_data_q <= diff_data;
			diff_data_valid_q <= diff_data_valid;
		end

	// output buffer
	always @ (posedge clk)
		if(!rst_n)
			data_src_sel <= 0;
		else if(frame_start_rise)
			case(frame_type_q)
				FRAME_A : data_src_sel <= 1;
				FRAME_B : data_src_sel <= 1;
				default : data_src_sel <= 0;
			endcase
		else
			data_src_sel <= data_src_sel;

	always @ (posedge clk)
		if(!rst_n) begin
			data_out_r <= 0;
			data_out_valid_r <= 0;
		end
		else
			case ({diff_en_q, data_src_sel})
				2'b11 : begin
					data_out_r <= diff_data_q;
					data_out_valid_r <= diff_data_valid_q;
				end
				default : begin
					data_out_r <= data_in_q;
					data_out_valid_r <= data_in_valid_q;
				end
			endcase



	// mst state
	always @ (posedge clk)
		if(!rst_n)
			mst_state <= IDLE;
		else
			case(mst_state)
				IDLE : 
					if(frame_start_rise)
						case(frame_type_q)
							FRAME_A : mst_state <= READ_FRAME;
							FRAME_B : mst_state <= READ_FRAME;
							default : mst_state <= STORE_FRAME;
						endcase
					else
						mst_state <= IDLE;

				STORE_FRAME : 
					if(waddr_r==18'h3ffff)
						mst_state <= DONE;
					else
						mst_state <= STORE_FRAME;

				READ_FRAME : 
					if(raddr_r==18'h3ffff)
						mst_state <= DONE;
					else
						mst_state <= READ_FRAME;

				DONE : 
					mst_state <= IDLE;

			endcase // mst_state

	// output logic
	assign waddr = waddr_r;
	assign wdata = wdata_r;
	assign wvalid = wvalid_r;
	assign raddr = raddr_r;
	assign data_out = data_out_r;
	assign data_out_valid = data_out_valid_r;

endmodule