// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cdc_sync_bit.v
// Create : 2019-03-28 13:35:51
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

	module cdc_sync_bits #(
		// Number of bits to synchronize
		parameter NUM_OF_BITS = 1,
		// Whether input and output clocks are asynchronous, if 0 the synchronizer will
		// be bypassed and the output signal equals the input signal.
		parameter ASYNC_CLK   = 1
	)(
		input  [NUM_OF_BITS-1:0] in        ,
		input                    out_resetn,
		input                    out_clk   ,
		output [NUM_OF_BITS-1:0] out
	);

	generate if (ASYNC_CLK == 1) begin
			(* ASYNC_REG="true" *)reg [NUM_OF_BITS-1:0] cdc_sync_stage1 = 'h0;
			(* ASYNC_REG="true" *)reg [NUM_OF_BITS-1:0] cdc_sync_stage2 = 'h0;

			always @(posedge out_clk)
				begin
					if (out_resetn == 1'b0) begin
						cdc_sync_stage1 <= 'b0;
						cdc_sync_stage2 <= 'b0;
					end else begin
						cdc_sync_stage1 <= in;
						cdc_sync_stage2 <= cdc_sync_stage1;
					end
				end
			assign out = cdc_sync_stage2;
		end else begin
			assign out = in;
		end endgenerate

	endmodule
