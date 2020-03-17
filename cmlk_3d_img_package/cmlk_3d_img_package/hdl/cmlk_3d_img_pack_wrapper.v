// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_3d_img_pack_wrapper.v
// Create : 2020-03-16 16:02:57
// Revised: 2020-03-16 16:34:58
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module cmlk_3d_img_pack_wrapper (
		input         aclk         ,
		input         aresetn      ,
		input         init_txn     , // TODO
		// input stream
		input  [15:0] nom_out      ,
		input         nom_out_vld  ,
		// output stream
		output [31:0] fifo_wrdata  ,
		output        fifo_wren    ,
		input         fifo_full    ,
		// misc
		input         frame_start  ,
		input  [ 1:0] frame_type_i ,
		output        frame_store  ,
		output        fifo_overflow,
		input         wr2ddr_en
	);

	wire int_resetn;
	wire [31:0] pack_data_in;
	wire pack_data_vld;

	assign int_resetn = aresetn & (~init_txn);

	cmlk_3d_data_repack cmlk_3d_data_repack_i0 (
		.clk      (aclk),
		.rst_n    (int_resetn),
		.din      (nom_out),
		.din_vld  (nom_out_vld),
		.dout     (pack_data_in),
		.dout_vld (pack_data_vld)
	);


	img_packet img_packet_i0 (
		.clk          (aclk         ),
		.rst_n        (int_resetn   ),
		.data_in      (pack_data_in ),
		.data_in_valid(pack_data_vld),
		.fifo_wrdata  (fifo_wrdata  ),
		.fifo_wren    (fifo_wren    ),
		.fifo_full    (fifo_full    ),
		.fifo_overflow(fifo_overflow),
		.frame_start  (frame_start  ),
		.frame_type_i (frame_type_i ),
		.frame_store  (frame_store  ),
		.frame_type_o (             ),
		.wr2ddr_en    (wr2ddr_en    )
	);

endmodule