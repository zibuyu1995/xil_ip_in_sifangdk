// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : ddr3_cache_ctrl_v1_0_AXI4_M_tb.sv
// Create : 2019-03-28 16:52:19
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module ddr3_cache_ctrl_v1_0_AXI4_M_tb; /* this is automatically generated */

	logic M_AXI_ACLK;
	logic rxclka;
	logic M_AXI_ARESETN;

	// clock
	initial begin
		M_AXI_ACLK = '0;
		forever #(2.5) M_AXI_ACLK = ~M_AXI_ACLK;
	end
	initial begin
		rxclka = '0;
		forever #(4.096) rxclka = ~rxclka;
	end

	// reset
	initial begin
		M_AXI_ARESETN = '0;
		#200
		@(posedge M_AXI_ACLK)
		M_AXI_ARESETN = '1;
	end

	// (*NOTE*) replace reset, clock, others

	parameter C_M_TARGET_SLAVE_BASE_ADDR   = 32'h00000000;
	parameter integer C_M_AXI_BURST_LEN    = 8;
	parameter integer C_M_AXI_ID_WIDTH     = 4;
	parameter integer C_M_AXI_ADDR_WIDTH   = 32;
	parameter integer C_M_AXI_DATA_WIDTH   = 256;
	parameter integer C_M_AXI_AWUSER_WIDTH = 0;
	parameter integer C_M_AXI_ARUSER_WIDTH = 0;
	parameter integer C_M_AXI_WUSER_WIDTH  = 0;
	parameter integer C_M_AXI_RUSER_WIDTH  = 0;
	parameter integer C_M_AXI_BUSER_WIDTH  = 0;

	logic                              rxdpram_wr_int;
	logic                              rxdpram_wr_done;
	logic                              fetch_updata_int;
	logic                              up_start_frame_num_update;
	logic                       [15:0] up_start_frame_num;
	logic                              updata_cfg_en;
	logic                       [15:0] updata_frame_num;
	logic                        [3:0] updata_subframe_num;
	logic                              init_calib_complete;
	logic                       [ 9:0] rxdpram_addrb_a0;
	logic                       [ 9:0] rxdpram_addrb_a1;
	logic                      [127:0] rxdpram_dout_a0;
	logic                      [127:0] rxdpram_dout_a1;
	logic                              txdpram_wea_a0;
	logic                              txdpram_wea_a1;
	logic                       [ 9:0] txdpram_addra_a0;
	logic                       [ 9:0] txdpram_addra_a1;
	logic                      [127:0] txdpram_din_a0;
	logic                      [127:0] txdpram_din_a1;
	logic                              ERROR;
	logic     [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID;
	logic   [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR;
	logic                      [7 : 0] M_AXI_AWLEN;
	logic                      [2 : 0] M_AXI_AWSIZE;
	logic                      [1 : 0] M_AXI_AWBURST;
	logic                              M_AXI_AWLOCK;
	logic                      [3 : 0] M_AXI_AWCACHE;
	logic                      [2 : 0] M_AXI_AWPROT;
	logic                      [3 : 0] M_AXI_AWQOS;
	logic [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER;
	logic                              M_AXI_AWVALID;
	logic                              M_AXI_AWREADY;
	logic   [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA;
	logic [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB;
	logic                              M_AXI_WLAST;
	logic  [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER;
	logic                              M_AXI_WVALID;
	logic                              M_AXI_WREADY;
	logic     [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID;
	logic                      [1 : 0] M_AXI_BRESP;
	logic  [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER;
	logic                              M_AXI_BVALID;
	logic                              M_AXI_BREADY;
	logic     [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID;
	logic   [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR;
	logic                      [7 : 0] M_AXI_ARLEN;
	logic                      [2 : 0] M_AXI_ARSIZE;
	logic                      [1 : 0] M_AXI_ARBURST;
	logic                              M_AXI_ARLOCK;
	logic                      [3 : 0] M_AXI_ARCACHE;
	logic                      [2 : 0] M_AXI_ARPROT;
	logic                      [3 : 0] M_AXI_ARQOS;
	logic [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER;
	logic                              M_AXI_ARVALID;
	logic                              M_AXI_ARREADY;
	logic     [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID;
	logic   [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA;
	logic                      [1 : 0] M_AXI_RRESP;
	logic                              M_AXI_RLAST;
	logic  [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER;
	logic                              M_AXI_RVALID;
	logic                              M_AXI_RREADY;

	logic [11:0] rxdpram_addra_a0;
	logic [31:0] rxdpram_din_a0  ;
	logic        rxdpram_wea_a0  ;

	ddr3_cache_ctrl_v1_0_AXI4_M #(
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
		.C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
		.C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
		.C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
	) inst_ddr3_cache_ctrl_v1_0_AXI4_M (
		.rxdpram_wr_int            (rxdpram_wr_int),
		.rxdpram_wr_done           (rxdpram_wr_done),
		.fetch_updata_int          (fetch_updata_int),
		.up_start_frame_num_update (up_start_frame_num_update),
		.up_start_frame_num        (up_start_frame_num),
		.updata_cfg_en             (updata_cfg_en),
		.updata_frame_num          (updata_frame_num),
		.updata_subframe_num       (updata_subframe_num),
		.init_calib_complete       (init_calib_complete),
		.rxdpram_addrb_a0          (rxdpram_addrb_a0),
		.rxdpram_addrb_a1          (rxdpram_addrb_a1),
		.rxdpram_dout_a0           (rxdpram_dout_a0),
		.rxdpram_dout_a1           (rxdpram_dout_a1),
		.txdpram_wea_a0            (txdpram_wea_a0),
		.txdpram_wea_a1            (txdpram_wea_a1),
		.txdpram_addra_a0          (txdpram_addra_a0),
		.txdpram_addra_a1          (txdpram_addra_a1),
		.txdpram_din_a0            (txdpram_din_a0),
		.txdpram_din_a1            (txdpram_din_a1),
		.ERROR                     (ERROR),
		.M_AXI_ACLK                (M_AXI_ACLK),
		.M_AXI_ARESETN             (M_AXI_ARESETN),
		.M_AXI_AWID                (M_AXI_AWID),
		.M_AXI_AWADDR              (M_AXI_AWADDR),
		.M_AXI_AWLEN               (M_AXI_AWLEN),
		.M_AXI_AWSIZE              (M_AXI_AWSIZE),
		.M_AXI_AWBURST             (M_AXI_AWBURST),
		.M_AXI_AWLOCK              (M_AXI_AWLOCK),
		.M_AXI_AWCACHE             (M_AXI_AWCACHE),
		.M_AXI_AWPROT              (M_AXI_AWPROT),
		.M_AXI_AWQOS               (M_AXI_AWQOS),
		.M_AXI_AWUSER              (M_AXI_AWUSER),
		.M_AXI_AWVALID             (M_AXI_AWVALID),
		.M_AXI_AWREADY             (M_AXI_AWREADY),
		.M_AXI_WDATA               (M_AXI_WDATA),
		.M_AXI_WSTRB               (M_AXI_WSTRB),
		.M_AXI_WLAST               (M_AXI_WLAST),
		.M_AXI_WUSER               (M_AXI_WUSER),
		.M_AXI_WVALID              (M_AXI_WVALID),
		.M_AXI_WREADY              (M_AXI_WREADY),
		.M_AXI_BID                 (M_AXI_BID),
		.M_AXI_BRESP               (M_AXI_BRESP),
		.M_AXI_BUSER               (M_AXI_BUSER),
		.M_AXI_BVALID              (M_AXI_BVALID),
		.M_AXI_BREADY              (M_AXI_BREADY),
		.M_AXI_ARID                (M_AXI_ARID),
		.M_AXI_ARADDR              (M_AXI_ARADDR),
		.M_AXI_ARLEN               (M_AXI_ARLEN),
		.M_AXI_ARSIZE              (M_AXI_ARSIZE),
		.M_AXI_ARBURST             (M_AXI_ARBURST),
		.M_AXI_ARLOCK              (M_AXI_ARLOCK),
		.M_AXI_ARCACHE             (M_AXI_ARCACHE),
		.M_AXI_ARPROT              (M_AXI_ARPROT),
		.M_AXI_ARQOS               (M_AXI_ARQOS),
		.M_AXI_ARUSER              (M_AXI_ARUSER),
		.M_AXI_ARVALID             (M_AXI_ARVALID),
		.M_AXI_ARREADY             (M_AXI_ARREADY),
		.M_AXI_RID                 (M_AXI_RID),
		.M_AXI_RDATA               (M_AXI_RDATA),
		.M_AXI_RRESP               (M_AXI_RRESP),
		.M_AXI_RLAST               (M_AXI_RLAST),
		.M_AXI_RUSER               (M_AXI_RUSER),
		.M_AXI_RVALID              (M_AXI_RVALID),
		.M_AXI_RREADY              (M_AXI_RREADY)
	);

	blk_mem_gen_0 blk_mem_gen_0_i0 (
		.rsta_busy    (             ),
		.rstb_busy    (             ),
		.s_aclk       (M_AXI_ACLK   ),
		.s_aresetn    (M_AXI_ARESETN),
		.s_axi_awid   (M_AXI_AWID   ),
		.s_axi_awaddr (M_AXI_AWADDR ),
		.s_axi_awlen  (M_AXI_AWLEN  ),
		.s_axi_awsize (M_AXI_AWSIZE ),
		.s_axi_awburst(M_AXI_AWBURST),
		.s_axi_awvalid(M_AXI_AWVALID),
		.s_axi_awready(M_AXI_AWREADY),
		.s_axi_wdata  (M_AXI_WDATA  ),
		.s_axi_wstrb  (M_AXI_WSTRB  ),
		.s_axi_wlast  (M_AXI_WLAST  ),
		.s_axi_wvalid (M_AXI_WVALID ),
		.s_axi_wready (M_AXI_WREADY ),
		.s_axi_bid    (M_AXI_BID    ),
		.s_axi_bresp  (M_AXI_BRESP  ),
		.s_axi_bvalid (M_AXI_BVALID ),
		.s_axi_bready (M_AXI_BREADY ),
		.s_axi_arid   (M_AXI_ARID   ),
		.s_axi_araddr (M_AXI_ARADDR ),
		.s_axi_arlen  (M_AXI_ARLEN  ),
		.s_axi_arsize (M_AXI_ARSIZE ),
		.s_axi_arburst(M_AXI_ARBURST),
		.s_axi_arvalid(M_AXI_ARVALID),
		.s_axi_arready(M_AXI_ARREADY),
		.s_axi_rid    (M_AXI_RID    ),
		.s_axi_rdata  (M_AXI_RDATA  ),
		.s_axi_rresp  (M_AXI_RRESP  ),
		.s_axi_rlast  (M_AXI_RLAST  ),
		.s_axi_rvalid (M_AXI_RVALID ),
		.s_axi_rready (M_AXI_RREADY )
	);

	blk_mem_gen_1 rxdpram_i0(
		.clka  (rxclka),
		.wea   (rxdpram_wea_a0),
		.addra (rxdpram_addra_a0),
		.dina  (rxdpram_din_a0),
		.clkb  (M_AXI_ACLK),
		.addrb (rxdpram_addrb_a0),
		.doutb (rxdpram_dout_a0)
	);

	blk_mem_gen_1 rxdpram_i1(
		.clka  (rxclka),
		.wea   (rxdpram_wea_a0),
		.addra (rxdpram_addra_a0),
		.dina  (rxdpram_din_a0),
		.clkb  (M_AXI_ACLK),
		.addrb (rxdpram_addrb_a1),
		.doutb (rxdpram_dout_a1)
	);



	initial begin
		// do something
		rxdpram_wr_int = 0;
		rxdpram_wea_a0 = 0;
		rxdpram_din_a0 = '0;
		rxdpram_addra_a0 = '0;
		updata_cfg_en = 0;
		updata_frame_num = 0;
		updata_subframe_num = 0;
		up_start_frame_num = 0;
		up_start_frame_num_update = 0;
		init_calib_complete = 0;
		#2000
		@(posedge M_AXI_ACLK)
		init_calib_complete = 1;
		@(posedge M_AXI_ACLK)
		up_start_frame_num_update = 0;
		@(posedge M_AXI_ACLK)
		up_start_frame_num_update = 1;
		@(posedge rxclka)
		rxdpram_wea_a0 = 1;
		rxdpram_din_a0 = rxdpram_din_a0 + 1;
		repeat(4095) begin
			@(posedge rxclka)
			rxdpram_wea_a0 = 1;
			rxdpram_addra_a0 = rxdpram_addra_a0 + 1;
			rxdpram_din_a0 = rxdpram_din_a0 + 1;
		end
		@(posedge rxclka)
		rxdpram_wea_a0 = 0;
		#200
		@(posedge M_AXI_ACLK)
		repeat(1) begin		
			@(posedge M_AXI_ACLK)
			rxdpram_wr_int = 1;
			@(posedge rxdpram_wr_done)
			#200
			@(posedge M_AXI_ACLK)
			rxdpram_wr_int = 0;
		end

		@(posedge rxclka)
		rxdpram_wea_a0 = 1;
		rxdpram_addra_a0 = rxdpram_addra_a0 + 1;
		rxdpram_din_a0 = rxdpram_din_a0 + 1;
		repeat(4095) begin
			@(posedge rxclka)
			rxdpram_wea_a0 = 1;
			rxdpram_addra_a0 = rxdpram_addra_a0 + 1;
			rxdpram_din_a0 = rxdpram_din_a0 + 1;
		end
		@(posedge rxclka)
		rxdpram_wea_a0 = 0;
		#200
		@(posedge M_AXI_ACLK)
		repeat(1) begin		
			@(posedge M_AXI_ACLK)
			rxdpram_wr_int = 1;
			@(posedge rxdpram_wr_done)
			#200
			@(posedge M_AXI_ACLK)
			rxdpram_wr_int = 0;
		end

		#200
		@(posedge M_AXI_ACLK)
		repeat(1) begin		
			@(posedge M_AXI_ACLK)
			updata_cfg_en = 1;
			@(posedge fetch_updata_int)
			#200
			@(posedge M_AXI_ACLK)
			updata_cfg_en = 0;
		end

		@(posedge M_AXI_ACLK)
		up_start_frame_num = 163;
		up_start_frame_num_update = 0;
		@(posedge M_AXI_ACLK)
		up_start_frame_num_update = 1;
		#200000
		repeat(10)@(posedge M_AXI_ACLK);
		$stop;
	end

	// dump wave
	// initial begin
	// 	if ( $test$plusargs("fsdb") ) begin
	// 		$fsdbDumpfile("tb_ddr3_cache_ctrl_v1_0_AXI4_M.fsdb");
	// 		$fsdbDumpvars(0, "tb_ddr3_cache_ctrl_v1_0_AXI4_M", "+mda", "+functions");
	// 	end
	// end

endmodule
