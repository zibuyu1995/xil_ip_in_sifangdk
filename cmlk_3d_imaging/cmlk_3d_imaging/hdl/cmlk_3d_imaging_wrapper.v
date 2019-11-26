// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_3d_imaging_wrapper.v
// Create : 2019-11-25 15:06:45
// Revised: 2019-11-26 16:26:29
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module cmlk_3d_imaging_wrapper (
	input         clk                 , // Clock
	input         rst_n               , // Synchronous reset active low
	input  [15:0] delay_a             ,
	input  [15:0] gate_width          ,
	input  [ 7:0] thres               ,
	input  [ 1:0] frame_type          ,
	// fifo a
	input  [ 7:0] s00_axis_tdata      ,
	input         s00_axis_tvalid     ,
	input         s00_axis_tlast      ,
	output        s00_axis_tready     ,
	// fifo b
	input  [ 7:0] s01_axis_tdata      ,
	input         s01_axis_tvalid     ,
	input         s01_axis_tlast      ,
	output        s01_axis_tready     ,
	// ddr cache fifo
	// write
	output [31:0] fifo_wrdata         ,
	output        fifo_wren           ,
	input         fifo_full           ,
	// read
	input  [31:0] fifo_rddata         ,
	output        fifo_rden           ,
	input         fifo_empty          ,
	// output
	output [ 7:0] nom_out             ,
	output        nom_out_vld         ,
	output [31:0] max_out             ,
	output [31:0] min_out
);

	wire [7:0] data_a_fifo;
	wire [7:0] data_b_fifo;
	wire data_fifo_vld;

	wire [31:0] data_out_threeD;
	wire data_out_threeD_vld;
	wire nom_rd;
	wire [31:0] threeD_fifo_dout;
	wire threeD_fifo_dout_vld;

	wire stream_data_ready;

	// input stream
	assign stream_data_ready = ({s00_axis_tvalid, s01_axis_tvalid}==2'b11);
	assign s00_axis_tready = stream_data_ready;
	assign s01_axis_tready = stream_data_ready;

	assign data_fifo_vld = stream_data_ready;
	assign data_a_fifo = s00_axis_tdata;
	assign data_b_fifo = s01_axis_tdata;

	// data cache
	assign fifo_wrdata = data_out_threeD;
	assign fifo_wren = data_out_threeD_vld;

	assign fifo_rden = ({nom_rd, fifo_empty}==2'b10);
	assign threeD_fifo_dout = fifo_rddata;
	assign threeD_fifo_dout_vld = fifo_rden;

	threeD threeD_i0 (
		.clk                 (clk                 ),
		.rst                 (~rst_n              ),
		.delay_a             (delay_a             ),
		.gate_width          (gate_width          ),
		.thres               (thres               ),
		.frame_type          (frame_type          ),
		.data_a_fifo         (data_a_fifo         ),
		.data_b_fifo         (data_b_fifo         ),
		.data_fifo_vld       (data_fifo_vld       ),
		.data_out_threeD     (data_out_threeD     ),
		.data_out_threeD_vld (data_out_threeD_vld ),
		.nom_rd              (nom_rd              ),
		.threeD_fifo_dout    (threeD_fifo_dout    ),
		.threeD_fifo_dout_vld(threeD_fifo_dout_vld),
		.nom_out             (nom_out             ),
		.nom_out_vld         (nom_out_vld         ),
		.max_out             (max_out             ),
		.min_out             (min_out             )
	);


endmodule