// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : udp_checksum16.v
// Create : 2019-04-12 23:48:56
// Editor : sublime text3, tab size (4)
// Coding : utf-8
// -----------------------------------------------------------------------------
module udp_checksum16(
	input  wire        clk          , // Clock
	input  wire        rst_n        , // Asynchronous reset active low
	input  wire [31:0] ip_src       ,
	input  wire [31:0] ip_dst       ,
	input  wire [15:0] udp_len      ,
	input  wire [15:0] port_src     ,
	input  wire [15:0] port_dst     ,
	input  wire [ 7:0] udp_data     ,
	input  wire        udp_data_en  ,
	output wire [15:0] udp_check_sum
);

	 

endmodule