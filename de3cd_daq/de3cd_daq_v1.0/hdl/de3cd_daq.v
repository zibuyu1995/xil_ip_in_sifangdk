// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : de3cd_daq.v
// Create : 2019-07-16 09:54:38
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module de3cd_daq #(parameter CLK_FREQ = 100_000_000) (
		// clock & reset
		input          clk                ,
		input          rst_n              ,
		// ads8556 data interface
		output         ads8556_1_wrn      ,
		output         ads8556_1_rdn      ,
		output         ads8556_1_csn      ,
		input          ads8556_1_busy     ,
		inout  [ 15:0] ads8556_1_data     ,
		output         ads8556_2_wrn      ,
		output         ads8556_2_rdn      ,
		output         ads8556_2_csn      ,
		input          ads8556_2_busy     ,
		inout  [ 15:0] ads8556_2_data     ,
		// ads8556 control interface
		output         ads8556_1_conv     ,
		output         ads8556_1_standbyn ,
		output         ads8556_1_reset    ,
		output         ads8556_2_conv     ,
		output         ads8556_2_standbyn ,
		output         ads8556_2_reset    ,
		// tcd1304 control interface
		output [  9:0] tcd1304_phi_m      ,
		output [  9:0] tcd1304_sh         , // tint range -- 10us ~ 6,553,510us, step 100us
		output [  9:0] tcd1304_icg        ,
		// config ports
		input  [ 15:0] tint_var           ,
		input  [  1:0] sync_phase         ,
		input          tint_load          ,
		// test port
		output [ 15:0] chip1_cross        ,
		output [ 15:0] chip2_cross        ,
		// data out ports
		output [159:0] tcd1304_dout       ,
		output [  9:0] tcd1304_valid      ,
		output [  9:0] tcd1304_frame_start
	);

	wire [15:0] ads8556_dout[9:0];
	wire [15:0] ads8556_cross[1:0];
	wire [1:0] ads8556_valid;

	wire data_clk2m;

	wire tcd1304_phi_m_w;
	wire tcd1304_sh_w;
	wire tcd1304_icg_w; 

	wire ads8556_syncn;

	wire [15:0] tcd1304_dout_w[9:0];
	wire [9:0] tcd1304_valid_w;
	wire [9:0] tcd1304_frame_start_w;

	genvar i;

	ads8556_wrraper #(
		.CLK_FREQ(CLK_FREQ)
	) ads8556_wrraper_i0 (
		.clk              (clk),
		.rst_n            (rst_n),
		.ads8556_wrn      (ads8556_1_wrn),
		.ads8556_rdn      (ads8556_1_rdn),
		.ads8556_csn      (ads8556_1_csn),
		.ads8556_busy     (ads8556_1_busy),
		.ads8556_data     (ads8556_1_data),
		.ads8556_syncn    (ads8556_syncn),
		.ads8556_conv     (ads8556_1_conv),
		.ads8556_standbyn (ads8556_1_standbyn),
		.ads8556_reset    (ads8556_1_reset),
		.data_ch0         (ads8556_cross[0]),
		.data_ch1         (ads8556_dout[0]),
		.data_ch2         (ads8556_dout[1]),
		.data_ch3         (ads8556_dout[2]),
		.data_ch4         (ads8556_dout[3]),
		.data_ch5         (ads8556_dout[4]),
		.data_valid       (ads8556_valid[0]),
		.data_clk2m       (data_clk2m)
	);

	ads8556_wrraper #(
		.CLK_FREQ(CLK_FREQ)
	) ads8556_wrraper_i1 (
		.clk              (clk),
		.rst_n            (rst_n),
		.ads8556_wrn      (ads8556_2_wrn),
		.ads8556_rdn      (ads8556_2_rdn),
		.ads8556_csn      (ads8556_2_csn),
		.ads8556_busy     (ads8556_2_busy),
		.ads8556_data     (ads8556_2_data),
		.ads8556_syncn    (ads8556_syncn),
		.ads8556_conv     (ads8556_2_conv),
		.ads8556_standbyn (ads8556_2_standbyn),
		.ads8556_reset    (ads8556_2_reset),
		.data_ch0         (ads8556_dout[5]),
		.data_ch1         (ads8556_dout[6]),
		.data_ch2         (ads8556_dout[7]),
		.data_ch3         (ads8556_dout[8]),
		.data_ch4         (ads8556_dout[9]),
		.data_ch5         (ads8556_cross[1]),
		.data_valid       (ads8556_valid[1]),
		.data_clk2m       ()
	);

	de3cd_multichip_sync de3cd_multichip_sync_i0 (
		.clk           (clk),
		.rst_n         (rst_n),
		.clk_2m        (data_clk2m),
		.tcd1304_sh    (tcd1304_sh_w),
		.sync_phase    (sync_phase),
		.tcd1304_load  (tint_load),
		.ads8556_syncn (ads8556_syncn)
	);

	tcd1304_ctrl tcd1304_ctrl_i0(
		.clk           (clk),
		.rst_n         (rst_n),
		.tcd1304_phi_m (tcd1304_phi_m_w),
		.tcd1304_sh    (tcd1304_sh_w),
		.tcd1304_icg   (tcd1304_icg_w),
		.tint_var      (tint_var),
		.tint_load     (tint_load),
		.clk2m         (data_clk2m)
	);

	generate
		for(i=0; i<10; i=i+1) begin
			if(i<5) begin
				tcd1304_daq tcd1304_daq_l_i (
					.clk                (clk                   ),
					.rst_n              (rst_n                 ),
					.tcd1304_din        (ads8556_dout[i]       ),
					.tcd1304_din_valid  (ads8556_valid[0]      ),
					.tcd1304_icg        (tcd1304_icg_w         ),
					.tcd1304_dout       (tcd1304_dout_w[i]     ),
					.tcd1304_dout_valid (tcd1304_valid_w[i]    ),
					.tcd1304_frame_start(tcd1304_frame_start[i])
				);
			end
			else begin
				tcd1304_daq tcd1304_daq_h_i (
					.clk                (clk                   ),
					.rst_n              (rst_n                 ),
					.tcd1304_din        (ads8556_dout[i]       ),
					.tcd1304_din_valid  (ads8556_valid[1]      ),
					.tcd1304_icg        (tcd1304_icg_w         ),
					.tcd1304_dout       (tcd1304_dout_w[i]     ),
					.tcd1304_dout_valid (tcd1304_valid_w[i]    ),
					.tcd1304_frame_start(tcd1304_frame_start[i])
				);
			end
		end
	endgenerate

	assign tcd1304_phi_m = {10{tcd1304_phi_m_w}};
	assign tcd1304_sh = {10{tcd1304_sh_w}};
	assign tcd1304_icg = {10{tcd1304_icg_w}};

	assign tcd1304_dout[15:0]    = tcd1304_dout_w[2];
	assign tcd1304_dout[31:16]   = tcd1304_dout_w[1];
	assign tcd1304_dout[47:32]   = tcd1304_dout_w[0];
	assign tcd1304_dout[63:48]   = tcd1304_dout_w[9];
	assign tcd1304_dout[79:64]   = tcd1304_dout_w[8];
	assign tcd1304_dout[95:80]   = tcd1304_dout_w[7];
	assign tcd1304_dout[111:96]  = tcd1304_dout_w[3];
	assign tcd1304_dout[127:112] = tcd1304_dout_w[4];
	assign tcd1304_dout[143:128] = tcd1304_dout_w[5];
	assign tcd1304_dout[159:144] = tcd1304_dout_w[6];

	assign tcd1304_valid[0] = tcd1304_valid_w[2];
	assign tcd1304_valid[1] = tcd1304_valid_w[1];
	assign tcd1304_valid[2] = tcd1304_valid_w[0];
	assign tcd1304_valid[3] = tcd1304_valid_w[9];
	assign tcd1304_valid[4] = tcd1304_valid_w[8];
	assign tcd1304_valid[5] = tcd1304_valid_w[7];
	assign tcd1304_valid[6] = tcd1304_valid_w[3];
	assign tcd1304_valid[7] = tcd1304_valid_w[4];
	assign tcd1304_valid[8] = tcd1304_valid_w[5];
	assign tcd1304_valid[9] = tcd1304_valid_w[6];

	assign tcd1304_frame_start[0] = tcd1304_frame_start_w[2];
	assign tcd1304_frame_start[1] = tcd1304_frame_start_w[1];
	assign tcd1304_frame_start[2] = tcd1304_frame_start_w[0];
	assign tcd1304_frame_start[3] = tcd1304_frame_start_w[9];
	assign tcd1304_frame_start[4] = tcd1304_frame_start_w[8];
	assign tcd1304_frame_start[5] = tcd1304_frame_start_w[7];
	assign tcd1304_frame_start[6] = tcd1304_frame_start_w[3];
	assign tcd1304_frame_start[7] = tcd1304_frame_start_w[4];
	assign tcd1304_frame_start[8] = tcd1304_frame_start_w[5];
	assign tcd1304_frame_start[9] = tcd1304_frame_start_w[6];

	assign chip1_cross = ads8556_cross[0];
	assign chip2_cross = ads8556_cross[1];

endmodule
