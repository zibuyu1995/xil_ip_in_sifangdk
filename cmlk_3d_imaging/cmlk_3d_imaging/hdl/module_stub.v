// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Fri Nov 22 20:33:11 2019
// Host        : LAPTOP-351VCBIM running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub -force module_stub.v
// Design      : threeD
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module threeD(clk, rst, delay_a, gate_width, thres, frame_type, 
  data_a_fifo, data_b_fifo, data_fifo_vld, data_out_threeD, data_out_threeD_vld, nom_rd, 
  threeD_fifo_dout, threeD_fifo_dout_vld, nom_out, nom_out_vld, max_out, min_out)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,delay_a[15:0],gate_width[15:0],thres[7:0],frame_type[1:0],data_a_fifo[7:0],data_b_fifo[7:0],data_fifo_vld,data_out_threeD[31:0],data_out_threeD_vld,nom_rd,threeD_fifo_dout[31:0],threeD_fifo_dout_vld,nom_out[7:0],nom_out_vld,max_out[31:0],min_out[31:0]" */;
  input clk;
  input rst;
  input [15:0]delay_a;
  input [15:0]gate_width;
  input [7:0]thres;
  input [1:0]frame_type;
  input [7:0]data_a_fifo;
  input [7:0]data_b_fifo;
  input data_fifo_vld;
  output [31:0]data_out_threeD;
  output data_out_threeD_vld;
  output nom_rd;
  input [31:0]threeD_fifo_dout;
  input threeD_fifo_dout_vld;
  output [7:0]nom_out;
  output nom_out_vld;
  output [31:0]max_out;
  output [31:0]min_out;
endmodule
