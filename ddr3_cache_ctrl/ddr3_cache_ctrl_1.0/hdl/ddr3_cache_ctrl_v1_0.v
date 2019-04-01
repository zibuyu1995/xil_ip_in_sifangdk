// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : ddr3_cache_ctrl_v1_0.v
// Create : 2019-03-28 11:09:38
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

	module ddr3_cache_ctrl_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface AXI4_M
		parameter  C_AXI4_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
		parameter integer C_AXI4_M_BURST_LEN	= 8,
		parameter integer C_AXI4_M_ID_WIDTH	= 4,
		parameter integer C_AXI4_M_ADDR_WIDTH	= 32,
		parameter integer C_AXI4_M_DATA_WIDTH	= 256,
		parameter integer C_AXI4_M_AWUSER_WIDTH	= 0,
		parameter integer C_AXI4_M_ARUSER_WIDTH	= 0,
		parameter integer C_AXI4_M_WUSER_WIDTH	= 0,
		parameter integer C_AXI4_M_RUSER_WIDTH	= 0,
		parameter integer C_AXI4_M_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
		// config & command signals
		input wire rxdpram_clka, clk_125m, 
		input wire rxdpram_wr_int,
		output wire rxdpram_wr_done,
		output wire fetch_updata_int,
		input wire up_start_frame_num_update,
		input wire [15:0] up_start_frame_num,
		input wire updata_cfg_en,
		input wire [15:0] updata_frame_num,
		input wire [3:0] updata_subframe_num,
		input wire init_calib_complete,
		// data signals
		output wire [  9:0] rxdpram_addrb_a0, rxdpram_addrb_a1,
		input wire [127:0] rxdpram_dout_a0, rxdpram_dout_a1,
		output wire         txdpram_wea_a0, txdpram_wea_a1,
		output wire [  9:0] txdpram_addra_a0, txdpram_addra_a1,
		output wire [127:0] txdpram_din_a0, txdpram_din_a1,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface AXI4_M
		output wire  axi4_m_error,
		input wire  axi4_m_aclk,
		input wire  axi4_m_aresetn,
		output wire [C_AXI4_M_ID_WIDTH-1 : 0] axi4_m_awid,
		output wire [C_AXI4_M_ADDR_WIDTH-1 : 0] axi4_m_awaddr,
		output wire [7 : 0] axi4_m_awlen,
		output wire [2 : 0] axi4_m_awsize,
		output wire [1 : 0] axi4_m_awburst,
		output wire  axi4_m_awlock,
		output wire [3 : 0] axi4_m_awcache,
		output wire [2 : 0] axi4_m_awprot,
		output wire [3 : 0] axi4_m_awqos,
		output wire [C_AXI4_M_AWUSER_WIDTH-1 : 0] axi4_m_awuser,
		output wire  axi4_m_awvalid,
		input wire  axi4_m_awready,
		output wire [C_AXI4_M_DATA_WIDTH-1 : 0] axi4_m_wdata,
		output wire [C_AXI4_M_DATA_WIDTH/8-1 : 0] axi4_m_wstrb,
		output wire  axi4_m_wlast,
		output wire [C_AXI4_M_WUSER_WIDTH-1 : 0] axi4_m_wuser,
		output wire  axi4_m_wvalid,
		input wire  axi4_m_wready,
		input wire [C_AXI4_M_ID_WIDTH-1 : 0] axi4_m_bid,
		input wire [1 : 0] axi4_m_bresp,
		input wire [C_AXI4_M_BUSER_WIDTH-1 : 0] axi4_m_buser,
		input wire  axi4_m_bvalid,
		output wire  axi4_m_bready,
		output wire [C_AXI4_M_ID_WIDTH-1 : 0] axi4_m_arid,
		output wire [C_AXI4_M_ADDR_WIDTH-1 : 0] axi4_m_araddr,
		output wire [7 : 0] axi4_m_arlen,
		output wire [2 : 0] axi4_m_arsize,
		output wire [1 : 0] axi4_m_arburst,
		output wire  axi4_m_arlock,
		output wire [3 : 0] axi4_m_arcache,
		output wire [2 : 0] axi4_m_arprot,
		output wire [3 : 0] axi4_m_arqos,
		output wire [C_AXI4_M_ARUSER_WIDTH-1 : 0] axi4_m_aruser,
		output wire  axi4_m_arvalid,
		input wire  axi4_m_arready,
		input wire [C_AXI4_M_ID_WIDTH-1 : 0] axi4_m_rid,
		input wire [C_AXI4_M_DATA_WIDTH-1 : 0] axi4_m_rdata,
		input wire [1 : 0] axi4_m_rresp,
		input wire  axi4_m_rlast,
		input wire [C_AXI4_M_RUSER_WIDTH-1 : 0] axi4_m_ruser,
		input wire  axi4_m_rvalid,
		output wire  axi4_m_rready
	);

		// Users to add wire & reg
		wire rxdpram_wr_int_s;
		wire up_start_frame_num_update_s;
		wire [15:0] up_start_frame_num_s;
		wire updata_cfg_en_s;
		wire [15:0] updata_frame_num_s;
		wire [3:0] updata_subframe_num_s;

		// Instantiation of Axi Bus Interface AXI4_M
		ddr3_cache_ctrl_v1_0_AXI4_M # ( 
			.C_M_TARGET_SLAVE_BASE_ADDR(C_AXI4_M_TARGET_SLAVE_BASE_ADDR),
			.C_M_AXI_BURST_LEN(C_AXI4_M_BURST_LEN),
			.C_M_AXI_ID_WIDTH(C_AXI4_M_ID_WIDTH),
			.C_M_AXI_ADDR_WIDTH(C_AXI4_M_ADDR_WIDTH),
			.C_M_AXI_DATA_WIDTH(C_AXI4_M_DATA_WIDTH),
			.C_M_AXI_AWUSER_WIDTH(C_AXI4_M_AWUSER_WIDTH),
			.C_M_AXI_ARUSER_WIDTH(C_AXI4_M_ARUSER_WIDTH),
			.C_M_AXI_WUSER_WIDTH(C_AXI4_M_WUSER_WIDTH),
			.C_M_AXI_RUSER_WIDTH(C_AXI4_M_RUSER_WIDTH),
			.C_M_AXI_BUSER_WIDTH(C_AXI4_M_BUSER_WIDTH)
		)ddr3_cache_ctrl_v1_0_AXI4_M_inst(
			//DDR3 INITIAL DONE
			.init_calib_complete(init_calib_complete),
			//CONIFG & COMMAND SIGNAL
			.rxdpram_wr_int(rxdpram_wr_int_s),
			.rxdpram_wr_done(rxdpram_wr_done),
			.up_start_frame_num_update(up_start_frame_num_update_s),
			.up_start_frame_num(up_start_frame_num_s),
			.updata_cfg_en(updata_cfg_en_s),
			.updata_frame_num(updata_frame_num_s),
			.updata_subframe_num(updata_subframe_num_s),
			.fetch_updata_int(fetch_updata_int),
			//DPRAM PORTS
			.rxdpram_addrb_a0(rxdpram_addrb_a0),
			.rxdpram_addrb_a1(rxdpram_addrb_a1),
			.rxdpram_dout_a0(rxdpram_dout_a0),
			.rxdpram_dout_a1(rxdpram_dout_a1),
			.txdpram_wea_a0(txdpram_wea_a0),
			.txdpram_wea_a1(txdpram_wea_a1),
			.txdpram_addra_a0(txdpram_addra_a0),
			.txdpram_addra_a1(txdpram_addra_a1),
			.txdpram_din_a0(txdpram_din_a0),
			.txdpram_din_a1(txdpram_din_a1),
			//AXI4 BUS
			.ERROR(axi4_m_error),
			.M_AXI_ACLK(axi4_m_aclk),
			.M_AXI_ARESETN(axi4_m_aresetn),
			.M_AXI_AWID(axi4_m_awid),
			.M_AXI_AWADDR(axi4_m_awaddr),
			.M_AXI_AWLEN(axi4_m_awlen),
			.M_AXI_AWSIZE(axi4_m_awsize),
			.M_AXI_AWBURST(axi4_m_awburst),
			.M_AXI_AWLOCK(axi4_m_awlock),
			.M_AXI_AWCACHE(axi4_m_awcache),
			.M_AXI_AWPROT(axi4_m_awprot),
			.M_AXI_AWQOS(axi4_m_awqos),
			.M_AXI_AWUSER(axi4_m_awuser),
			.M_AXI_AWVALID(axi4_m_awvalid),
			.M_AXI_AWREADY(axi4_m_awready),
			.M_AXI_WDATA(axi4_m_wdata),
			.M_AXI_WSTRB(axi4_m_wstrb),
			.M_AXI_WLAST(axi4_m_wlast),
			.M_AXI_WUSER(axi4_m_wuser),
			.M_AXI_WVALID(axi4_m_wvalid),
			.M_AXI_WREADY(axi4_m_wready),
			.M_AXI_BID(axi4_m_bid),
			.M_AXI_BRESP(axi4_m_bresp),
			.M_AXI_BUSER(axi4_m_buser),
			.M_AXI_BVALID(axi4_m_bvalid),
			.M_AXI_BREADY(axi4_m_bready),
			.M_AXI_ARID(axi4_m_arid),
			.M_AXI_ARADDR(axi4_m_araddr),
			.M_AXI_ARLEN(axi4_m_arlen),
			.M_AXI_ARSIZE(axi4_m_arsize),
			.M_AXI_ARBURST(axi4_m_arburst),
			.M_AXI_ARLOCK(axi4_m_arlock),
			.M_AXI_ARCACHE(axi4_m_arcache),
			.M_AXI_ARPROT(axi4_m_arprot),
			.M_AXI_ARQOS(axi4_m_arqos),
			.M_AXI_ARUSER(axi4_m_aruser),
			.M_AXI_ARVALID(axi4_m_arvalid),
			.M_AXI_ARREADY(axi4_m_arready),
			.M_AXI_RID(axi4_m_rid),
			.M_AXI_RDATA(axi4_m_rdata),
			.M_AXI_RRESP(axi4_m_rresp),
			.M_AXI_RLAST(axi4_m_rlast),
			.M_AXI_RUSER(axi4_m_ruser),
			.M_AXI_RVALID(axi4_m_rvalid),
			.M_AXI_RREADY(axi4_m_rready)
		);

		// Add user logic here
		// CDC synchronize
		cdc_sync_bits #(
			.NUM_OF_BITS(1),
			.ASYNC_CLK(1)
		)cdc_sync_rxdpram_wr_int_i0(
			.in         (rxdpram_wr_int),
			.out_resetn (axi4_m_aresetn),
			.out_clk    (axi4_m_aclk),
			.out        (rxdpram_wr_int_s)
		);

		cdc_sync_data #(
			.NUM_OF_BITS(17),
			.ASYNC_CLK(1)
		)cdc_sync_up_frame_i0(
			.in_clk   (rxdpram_clka),
			.in_data  ({up_start_frame_num_update, up_start_frame_num}),
			.out_clk  (axi4_m_aclk),
			.out_data ({up_start_frame_num_update_s, up_start_frame_num_s})
		);

		cdc_sync_data #(
			.NUM_OF_BITS(21),
			.ASYNC_CLK(1)
		)cdc_sync_updata_i0(
			.in_clk   (clk_125m),
			.in_data  ({updata_cfg_en, updata_frame_num, updata_subframe_num}),
			.out_clk  (axi4_m_aclk),
			.out_data ({updata_cfg_en_s, updata_frame_num_s, updata_subframe_num_s}) 
		);

		// User logic ends

	endmodule
