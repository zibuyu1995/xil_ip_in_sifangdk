// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : ads8556_wrraper.v
// Create : 2019-07-04 16:17:50
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module ads8556_wrraper #(parameter CLK_FREQ = 100_000_000)(
		// clock & reset
		input         clk             ,
		input         rst_n           ,
		// ads8556 data interface
		output        ads8556_wrn     ,
		output        ads8556_rdn     ,
		output        ads8556_csn     ,
		input         ads8556_busy    ,
		inout  [15:0] ads8556_data    ,
		// ads8556 control interface
		output        ads8556_conv    ,
		output        ads8556_standbyn,
		output        ads8556_reset   ,
		// data interface
		output [15:0] data_ch0        ,
		output [15:0] data_ch1        ,
		output [15:0] data_ch2        ,
		output [15:0] data_ch3        ,
		output [15:0] data_ch4        ,
		output [15:0] data_ch5        ,
		output        data_valid      ,
		// misc ports (option)
		output        data_clk2m
	);

	wire [15:0] ads8556_data_in;
	wire [15:0] ads8556_data_out;
	wire ads8556_data_t;

	ads8556_if #(
		.CLK_FREQ(CLK_FREQ)
	) ads8556_if_i0 (
		.clk              (clk),
		.rst_n            (rst_n),
		.ads8556_wrn      (ads8556_wrn),
		.ads8556_rdn      (ads8556_rdn),
		.ads8556_csn      (ads8556_csn),
		.ads8556_busy     (ads8556_busy),
		.ads8556_data_in  (ads8556_data_in),
		.ads8556_data_out (ads8556_data_out),
		.ads8556_data_t   (ads8556_data_t),
		.ads8556_conv     (ads8556_conv),
		.ads8556_standbyn (ads8556_standbyn),
		.ads8556_reset    (ads8556_reset),
		.data_ch0         (data_ch0),
		.data_ch1         (data_ch1),
		.data_ch2         (data_ch2),
		.data_ch3         (data_ch3),
		.data_ch4         (data_ch4),
		.data_ch5         (data_ch5),
		.data_valid       (data_valid),
		.data_clk2m       (data_clk2m)
	);

	genvar i;
	generate
		for(i=0; i<16; i=i+1) begin
			IOBUF #(
				.IBUF_LOW_PWR("FALSE"), // Low Power - "TRUE", High Performance = "FALSE"
				.SLEW        ("FAST" )  // Specify the output slew rate
			) iobuf_ads8556_data_i (
				.O (ads8556_data_in[i] ), // Buffer output
				.IO(ads8556_data[i]    ), // Buffer inout port (connect directly to top-level port)
				.I (ads8556_data_out[i]), // Buffer input
				.T (ads8556_data_t     )  // 3-state enable input, high=input, low=output
			);
		end
	endgenerate


endmodule
