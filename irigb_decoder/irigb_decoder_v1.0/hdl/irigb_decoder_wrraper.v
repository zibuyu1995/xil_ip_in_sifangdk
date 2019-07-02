// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : system_top.v
// Create : 2019-05-10 17:30:21
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module irigb_decoder_wrraper #(parameter CLKFREQ = 100_000_000) (
		input         clk          ,
		input         rst_n        ,
		input         irigb_rx     ,
		output [ 6:0] irigb_seconds,
		output [ 6:0] irigb_minutes,
		output [ 5:0] irigb_hours  ,
		output [ 9:0] irigb_days   ,
		output [ 7:0] irigb_years  ,
		output [17:0] irigb_cntls  ,
		output [16:0] irigb_sbs    ,
		output        irigb_valid
	);

	wire clk_10KHz;
	wire clk_1KHz;
	wire glbl_rst;

	assign glbl_rst = ~rst_n;

	irigb_clk_gen #(.CLKFREQ(CLKFREQ)) irigb_clk_gen_i0 (
		.rst          (glbl_rst ),
		.clk          (clk      ),
		.clk_10KHz_out(clk_10KHz),
		.clk_1KHz_out (clk_1KHz )
	);


	irigb_decoder irigb_decoder_i0 (
		.Clk10KHz  (clk_10KHz    ),
		.Clk       (clk_1KHz     ),
		.Reset     (glbl_rst     ),
		.RX        (irigb_rx     ),
		.UpdataFlag(irigb_valid  ),
		.SECONDS   (irigb_seconds),
		.MINUTES   (irigb_minutes),
		.HOURS     (irigb_hours  ),
		.DAYS      (irigb_days   ),
		.YEARS     (irigb_years  ),
		.CNTLS     (irigb_cntls  ),
		.SBS       (irigb_sbs    )
	);

	

endmodule
