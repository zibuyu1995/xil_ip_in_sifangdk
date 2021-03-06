// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_img_preproc.v
// Create : 2019-11-06 15:54:49
// Revised: 2020-03-31 13:50:04
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cmlk_img_preproc#(parameter ENABLE_EXT_TRIG_CNT = "TRUE")(
		input aclk,
		input aresetn,
		input init_txn,		// TODO
		// input stream
		input [63:0] s_axis_cmlk_tdata,
		input s_axis_cmlk_tlast,
		output s_axis_cmlk_tready,
		input s_axis_cmlk_tuser,
		input s_axis_cmlk_tvalid,
		// output stream
		output [31:0] fifo_wrdata,
		output fifo_wren,
		input fifo_full,
		// misc
		input ext_trig,
		output ext_trig_overflow,
		input diff_en,
		input wr2ddr_en,
		output fifo_overflow,
		output unexpected_data,
		output unexpected_tlast,
		input [1:0] frame_type_i,
		output frame_store,
		output [1:0] frame_type_o
    );

	wire [63:0] if_dout;
	wire if_dout_vld;
	wire frame_start;
	wire [1:0] frame_type;

	wire [31:0] binning_dout;
	wire binning_dout_vld;

	wire [31:0] diff_out;
	wire diff_out_vld;

	wire [17:0] bram_waddr;
	wire [31:0] bram_wdata;
	wire bram_wvalid;
	wire [17:0] bram_raddr;
	wire [31:0] bram_rdata;

	wire int_resetn;

	assign int_resetn = aresetn & (~init_txn);

	if_convert if_convert_i0 (
		.clk               (aclk              ),
		.rst_n             (int_resetn        ),
		.s_axis_cmlk_tdata (s_axis_cmlk_tdata ),
		.s_axis_cmlk_tlast (s_axis_cmlk_tlast ),
		.s_axis_cmlk_tready(s_axis_cmlk_tready),
		.s_axis_cmlk_tuser (s_axis_cmlk_tuser ),
		.s_axis_cmlk_tvalid(s_axis_cmlk_tvalid),
		.dout              (if_dout           ),
		.dout_vld          (if_dout_vld       ),
		.frame_type_i      (frame_type_i      ),
		.frame_start       (frame_start       ),
		.frame_type_o      (frame_type        ),
		.unexpected_data   (unexpected_data   ),
		.unexpected_tlast  (unexpected_tlast  )
	);

	img_deci img_deci_i0 (
		.clk        (aclk            ),
		.rst_n      (int_resetn      ),
		.din        (if_dout         ),
		.din_valid  (if_dout_vld     ),
		.dout       (binning_dout    ),
		.dout_valid (binning_dout_vld),
		.frame_start(frame_start     )
	);

	img_diff img_diff_i0 (
		.clk           (aclk            ),
		.rst_n         (int_resetn      ),
		.diff_en       (diff_en         ),
		.data_in       (binning_dout    ),
		.data_in_valid (binning_dout_vld),
		.data_out      (diff_out        ),
		.data_out_valid(diff_out_vld    ),
		.waddr         (bram_waddr      ),
		.wdata         (bram_wdata      ),
		.wvalid        (bram_wvalid     ),
		.raddr         (bram_raddr      ),
		.rdata         (bram_rdata      ),
		.frame_start   (frame_start     ),
		.frame_type    (frame_type      )
	);

	simple_sync_dpram #(.RAM_WIDTH(32), .RAM_DEPTH(262144)) simple_sync_dpram_i0 (
		.addra (bram_waddr ),
		.addrb (bram_raddr ),
		.dina  (bram_wdata ),
		.clka  (aclk       ),
		.wea   (bram_wvalid),
		.enb   (1'b1       ),
		.rstb  (~int_resetn),
		.regceb(1'b1       ),
		.doutb (bram_rdata )
	);

	img_packet #(
		.LINE_SIZE (1024),
		.IMAGE_SIZE(1024*1024),
		.PIX_SIZE  (8),
		.PKT_MODE  ("2D")
	) img_packet_i0 (
		.clk          (aclk         ),
		.rst_n        (int_resetn   ),
		.data_in      (diff_out     ),
		.data_in_valid(diff_out_vld ),
		.fifo_wrdata  (fifo_wrdata  ),
		.fifo_wren    (fifo_wren    ),
		.fifo_full    (fifo_full    ),
		.fifo_overflow(fifo_overflow),
		.frame_start  (frame_start  ),
		.frame_type_i (frame_type   ),
		.frame_store  (frame_store  ),
		.frame_type_o (frame_type_o ),
		.wr2ddr_en    (wr2ddr_en)
	);

	generate
		if(ENABLE_EXT_TRIG_CNT == "TRUE") begin
			ext_trig_cnt ext_trig_cnt_i0 (
				.clk              (aclk             ),
				.rst_n            (int_resetn       ),
				.en_cnt           (wr2ddr_en        ),
				.ext_trig         (ext_trig         ),
				.frame_start      (frame_start      ),
				.ext_trig_overflow(ext_trig_overflow)
			);
		end
	endgenerate

endmodule
