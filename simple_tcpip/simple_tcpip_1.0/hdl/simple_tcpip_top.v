// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author   : hao liang (Ash) a529481713@gmail.com
// File     : simple_tcpip_top.v
// Create   : 2019-04-10 22:38:36
// Editor   : sublime text3, tab size (4)
// Encoding : utf-8
// -----------------------------------------------------------------------------
`include "simple_tcpip_param.vh"

module simple_tcpip_top (
	// clock & reset
	input  wire        axi_tclk          , // Clock
	input  wire        axi_tresetn       , // synchronous reset active low
	// speed control
	input  wire [ 1:0] speed             , // 00---10Mbps 01---100Mbps 10---1Gbps
	input  wire        link_up           , // active high
	// data from the rx data path of MAC
	input  wire [ 7:0] rx_axis_tdata     ,
	input  wire        rx_axis_tvalid    ,
	input  wire        rx_axis_tlast     ,
	input  wire        rx_axis_tuser     ,
	output wire        rx_axis_tready    ,
	// data TO the tx data path of MAC
	output wire [ 7:0] tx_axis_tdata     ,
	output wire        tx_axis_tvalid    ,
	output wire        tx_axis_tlast     ,
	input  wire        tx_axis_tready    ,
	// user app data interface
	input  wire        tx_app_clk        ,
	input  wire [ 7:0] tx_app_data       ,
	input  wire        tx_app_wren       ,
	output wire        tx_app_full       ,
	output wire [ 7:0] rx_app_data       ,
	input  wire        rx_app_rden       ,
	output wire        rx_app_empty      ,
	// user app config
	input  wire [31:0] app_ip            ,
	input  wire        app_type          , //0---udp 1---tcp(to be done)
	input  wire [31:0] tx_app_dst_ip     ,
	input  wire [15:0] tx_app_src_port   ,
	input  wire [15:0] tx_app_dst_port   ,
	input  wire [15:0] rx_app_listen_port
);



endmodule