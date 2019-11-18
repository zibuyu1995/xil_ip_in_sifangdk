// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : shift_reg_bus.v
// Create : 2019-11-07 14:35:38
// Revised: 2019-11-07 16:08:06
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module shift_reg_bus#(
		parameter clock_cycles = 32,
		parameter data_width = 16
	)(
		input clk,
		input rst_n,
		//
		input [data_width-1:0] data_in,
		input data_valid,
		output [data_width-1:0] data_out
    );

   reg [clock_cycles-1:0] shift_reg [data_width-1:0];

   integer srl_index;
   initial
      for (srl_index = 0; srl_index < data_width; srl_index = srl_index + 1)
         shift_reg[srl_index] = {clock_cycles{1'b0}};

   genvar i;
   generate
      for (i=0; i < data_width; i=i+1)
      begin
         always @(posedge clk)
            if (data_valid)
               shift_reg[i] <= {shift_reg[i][clock_cycles-2:0], data_in[i]};

         assign data_out[i] = shift_reg[i][clock_cycles-1];
      end
   endgenerate

endmodule
