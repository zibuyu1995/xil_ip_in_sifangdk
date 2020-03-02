// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : hs400_tuning_ctrl.v
// Create : 2019-12-02 17:54:23
// Revised: 2020-03-02 14:54:54
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module hs400_tuning_ctrl(
		input clk,
		input rst,
		// controll interface
		input idly_tuning_start,
		output idly_tuning_ready,
		output idly_tuning_done,
		output idly_tuning_failed,
		input [23:0] idly_tuning_timeout,
		// data strobe signal
		input [1:0] data_strobe,
		// idelay interface
		output [4:0] cntval_in,
		output cntval_load,
		input [4:0] cntval_out
    );

	// TODO
	assign idly_tuning_ready = 0;
	assign idly_tuning_done = 0;
	assign idly_tuning_failed = 0;
	// assign cntval_in = 0;
	// assign cntval_load = 0;

	vio_6 vio_6_i0 (
		.clk       (clk        ), // input wire clk
		.probe_in0 (cntval_out ), // input wire [4 : 0] probe_in0
		.probe_out0(cntval_in  ), // output wire [4 : 0] probe_out0
		.probe_out1(cntval_load)  // output wire [0 : 0] probe_out1
	);

endmodule
