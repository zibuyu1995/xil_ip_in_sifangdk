// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_wrapper.v
// Create : 2019-10-22 10:56:13
// Revised: 2019-11-15 14:32:45
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cmlk_wrapper (
		input         clk               ,
		input         rst_n             ,
		// cmlk interface
		input         cmlk_clk_x        ,
		input  [27:0] cmlk_data_x       ,
		input         cmlk_clk_y        ,
		input  [27:0] cmlk_data_y       ,
		input         cmlk_clk_z        ,
		input  [27:0] cmlk_data_z       ,
		// axi4s interface
		output [63:0] m_axis_cmlk_tdata ,
		output        m_axis_cmlk_tlast ,
		input         m_axis_cmlk_tready,
		output        m_axis_cmlk_tuser ,
		output        m_axis_cmlk_tvalid,
		// misc
		output        fstart_err        ,
		output        lval_err          ,
		output        overflow
	);

	wire [27:0] cmlk_data_x_w;
	wire [27:0] cmlk_data_y_w;
	wire [27:0] cmlk_data_z_w;
	wire cmlk_data_valid_w;


	cmlk_if cmlk_if_i0(
		.clk               (clk),
		.rst_n             (rst_n),
		.cmlk_clk_x        (cmlk_clk_x),
		.cmlk_data_x       (cmlk_data_x),
		.cmlk_clk_y        (cmlk_clk_y),
		.cmlk_data_y       (cmlk_data_y),
		.cmlk_clk_z        (cmlk_clk_z),
		.cmlk_data_z       (cmlk_data_z),
		.cmlk_data_x_o     (cmlk_data_x_w),
		.cmlk_data_y_o     (cmlk_data_y_w),
		.cmlk_data_z_o     (cmlk_data_z_w),
		.cmlk_data_valid_o (cmlk_data_valid_w)
	);

	cmlk2axis cmlk2axis_i0(
		.clk                (clk),
		.rst_n              (rst_n),
		.cmlk_data_x        (cmlk_data_x_w),
		.cmlk_data_y        (cmlk_data_y_w),
		.cmlk_data_z        (cmlk_data_z_w),
		.cmlk_data_valid    (cmlk_data_valid_w),
		.m_axis_cmlk_tdata  (m_axis_cmlk_tdata),
		.m_axis_cmlk_tlast  (m_axis_cmlk_tlast),
		.m_axis_cmlk_tready (m_axis_cmlk_tready),
		.m_axis_cmlk_tuser  (m_axis_cmlk_tuser),
		.m_axis_cmlk_tvalid (m_axis_cmlk_tvalid),
		.fstart_err         (fstart_err),
		.lval_err           (lval_err),
		.overflow           (overflow)
	);



endmodule
