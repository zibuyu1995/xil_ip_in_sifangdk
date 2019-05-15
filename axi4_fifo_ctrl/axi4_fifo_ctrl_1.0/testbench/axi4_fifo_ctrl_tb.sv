// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : axi4_fifo_ctrl_tb.sv
// Create : 2019-05-14 11:38:02
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module axi4_fifo_ctrl_tb;


	logic rstb;
	logic srst;
	logic clk;

	// clock
	initial begin
		clk = '0;
		forever #(5) clk = ~clk;
	end

	// reset
	initial begin
		rstb <= '0;
		srst <= '1;
		#200
		repeat (5) @(posedge clk);
		rstb <= '1;
		srst <= '0;
	end

	// (*NOTE*) replace reset, clock, others

	parameter C_M00_AXI_TARGET_SLAVE_RANGE_ADDR = 32'h00000800;
	parameter C_M00_AXI_TARGET_SLAVE_BASE_ADDR  = 32'h00000000;
	parameter integer C_M00_AXI_BURST_LEN       = 8;
	parameter integer C_M00_AXI_ID_WIDTH        = 4;
	parameter integer C_M00_AXI_ADDR_WIDTH      = 32;
	parameter integer C_M00_AXI_DATA_WIDTH      = 256;
	parameter integer C_M00_AXI_AWUSER_WIDTH    = 0;
	parameter integer C_M00_AXI_ARUSER_WIDTH    = 0;
	parameter integer C_M00_AXI_WUSER_WIDTH     = 0;
	parameter integer C_M00_AXI_RUSER_WIDTH     = 0;
	parameter integer C_M00_AXI_BUSER_WIDTH     = 0;

	logic                                fifo_rden;
	logic   [C_M00_AXI_DATA_WIDTH-1 : 0] fifo_rddata;
	logic                                fifo_empty;
	logic                                fifo_prog_empty;
	logic                                fifo_wren;
	logic   [C_M00_AXI_DATA_WIDTH-1 : 0] fifo_wrdata;
	logic                                fifo_full;
	logic                                fifo_prog_full;
	logic                                m00_axi_init_axi_txn;
	logic                                m00_axi_txn_done;
	logic                                m00_axi_error;
	logic                                m00_axi_aclk;
	logic                                m00_axi_aresetn;
	logic     [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid;
	logic   [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr;
	logic                        [7 : 0] m00_axi_awlen;
	logic                        [2 : 0] m00_axi_awsize;
	logic                        [1 : 0] m00_axi_awburst;
	logic                                m00_axi_awlock;
	logic                        [3 : 0] m00_axi_awcache;
	logic                        [2 : 0] m00_axi_awprot;
	logic                        [3 : 0] m00_axi_awqos;
	logic [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser;
	logic                                m00_axi_awvalid;
	logic                                m00_axi_awready;
	logic   [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata;
	logic [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb;
	logic                                m00_axi_wlast;
	logic  [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser;
	logic                                m00_axi_wvalid;
	logic                                m00_axi_wready;
	logic     [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid;
	logic                        [1 : 0] m00_axi_bresp;
	logic  [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser;
	logic                                m00_axi_bvalid;
	logic                                m00_axi_bready;
	logic     [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid;
	logic   [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr;
	logic                        [7 : 0] m00_axi_arlen;
	logic                        [2 : 0] m00_axi_arsize;
	logic                        [1 : 0] m00_axi_arburst;
	logic                                m00_axi_arlock;
	logic                        [3 : 0] m00_axi_arcache;
	logic                        [2 : 0] m00_axi_arprot;
	logic                        [3 : 0] m00_axi_arqos;
	logic [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser;
	logic                                m00_axi_arvalid;
	logic                                m00_axi_arready;
	logic     [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid;
	logic   [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata;
	logic                        [1 : 0] m00_axi_rresp;
	logic                                m00_axi_rlast;
	logic  [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser;
	logic                                m00_axi_rvalid;
	logic                                m00_axi_rready;

	logic                                rdfifo_wren;
	logic   [C_M00_AXI_DATA_WIDTH-1 : 0] rdfifo_wrdata;

	axi4_fifo_ctrl_v1_0 #(
		.C_M00_AXI_TARGET_SLAVE_RANGE_ADDR(C_M00_AXI_TARGET_SLAVE_RANGE_ADDR),
		.C_M00_AXI_TARGET_SLAVE_BASE_ADDR (C_M00_AXI_TARGET_SLAVE_BASE_ADDR ),
		.C_M00_AXI_BURST_LEN              (C_M00_AXI_BURST_LEN              ),
		.C_M00_AXI_ID_WIDTH               (C_M00_AXI_ID_WIDTH               ),
		.C_M00_AXI_ADDR_WIDTH             (C_M00_AXI_ADDR_WIDTH             ),
		.C_M00_AXI_DATA_WIDTH             (C_M00_AXI_DATA_WIDTH             ),
		.C_M00_AXI_AWUSER_WIDTH           (C_M00_AXI_AWUSER_WIDTH           ),
		.C_M00_AXI_ARUSER_WIDTH           (C_M00_AXI_ARUSER_WIDTH           ),
		.C_M00_AXI_WUSER_WIDTH            (C_M00_AXI_WUSER_WIDTH            ),
		.C_M00_AXI_RUSER_WIDTH            (C_M00_AXI_RUSER_WIDTH            ),
		.C_M00_AXI_BUSER_WIDTH            (C_M00_AXI_BUSER_WIDTH            )
	) dut (
		.fifo_rden           (fifo_rden           ),
		.fifo_rddata         (fifo_rddata         ),
		.fifo_empty          (fifo_empty          ),
		.fifo_prog_empty     (fifo_prog_empty     ),
		.fifo_wren           (fifo_wren           ),
		.fifo_wrdata         (fifo_wrdata         ),
		.fifo_full           (fifo_full           ),
		.fifo_prog_full      (fifo_prog_full      ),
		.m00_axi_init_axi_txn(m00_axi_init_axi_txn),
		.m00_axi_error       (m00_axi_error       ),
		.m00_axi_aclk        (m00_axi_aclk        ),
		.m00_axi_aresetn     (m00_axi_aresetn     ),
		.m00_axi_awid        (m00_axi_awid        ),
		.m00_axi_awaddr      (m00_axi_awaddr      ),
		.m00_axi_awlen       (m00_axi_awlen       ),
		.m00_axi_awsize      (m00_axi_awsize      ),
		.m00_axi_awburst     (m00_axi_awburst     ),
		.m00_axi_awlock      (m00_axi_awlock      ),
		.m00_axi_awcache     (m00_axi_awcache     ),
		.m00_axi_awprot      (m00_axi_awprot      ),
		.m00_axi_awqos       (m00_axi_awqos       ),
		.m00_axi_awuser      (m00_axi_awuser      ),
		.m00_axi_awvalid     (m00_axi_awvalid     ),
		.m00_axi_awready     (m00_axi_awready     ),
		.m00_axi_wdata       (m00_axi_wdata       ),
		.m00_axi_wstrb       (m00_axi_wstrb       ),
		.m00_axi_wlast       (m00_axi_wlast       ),
		.m00_axi_wuser       (m00_axi_wuser       ),
		.m00_axi_wvalid      (m00_axi_wvalid      ),
		.m00_axi_wready      (m00_axi_wready      ),
		.m00_axi_bid         (m00_axi_bid         ),
		.m00_axi_bresp       (m00_axi_bresp       ),
		.m00_axi_buser       (m00_axi_buser       ),
		.m00_axi_bvalid      (m00_axi_bvalid      ),
		.m00_axi_bready      (m00_axi_bready      ),
		.m00_axi_arid        (m00_axi_arid        ),
		.m00_axi_araddr      (m00_axi_araddr      ),
		.m00_axi_arlen       (m00_axi_arlen       ),
		.m00_axi_arsize      (m00_axi_arsize      ),
		.m00_axi_arburst     (m00_axi_arburst     ),
		.m00_axi_arlock      (m00_axi_arlock      ),
		.m00_axi_arcache     (m00_axi_arcache     ),
		.m00_axi_arprot      (m00_axi_arprot      ),
		.m00_axi_arqos       (m00_axi_arqos       ),
		.m00_axi_aruser      (m00_axi_aruser      ),
		.m00_axi_arvalid     (m00_axi_arvalid     ),
		.m00_axi_arready     (m00_axi_arready     ),
		.m00_axi_rid         (m00_axi_rid         ),
		.m00_axi_rdata       (m00_axi_rdata       ),
		.m00_axi_rresp       (m00_axi_rresp       ),
		.m00_axi_rlast       (m00_axi_rlast       ),
		.m00_axi_ruser       (m00_axi_ruser       ),
		.m00_axi_rvalid      (m00_axi_rvalid      ),
		.m00_axi_rready      (m00_axi_rready      )
	);

	blk_mem_gen_0 blk_mem_gen_0_i0 (
		.rsta_busy    (               ), // output wire rsta_busy
		.rstb_busy    (               ), // output wire rstb_busy
		.s_aclk       (m00_axi_aclk   ), // input wire s_aclk
		.s_aresetn    (m00_axi_aresetn), // input wire s_aresetn
		.s_axi_awid   (m00_axi_awid   ), // input wire [3 : 0] s_axi_awid
		.s_axi_awaddr (m00_axi_awaddr ), // input wire [31 : 0] s_axi_awaddr
		.s_axi_awlen  (m00_axi_awlen  ), // input wire [7 : 0] s_axi_awlen
		.s_axi_awsize (m00_axi_awsize ), // input wire [2 : 0] s_axi_awsize
		.s_axi_awburst(m00_axi_awburst), // input wire [1 : 0] s_axi_awburst
		.s_axi_awvalid(m00_axi_awvalid), // input wire s_axi_awvalid
		.s_axi_awready(m00_axi_awready), // output wire s_axi_awready
		.s_axi_wdata  (m00_axi_wdata  ), // input wire [31 : 0] s_axi_wdata
		.s_axi_wstrb  (m00_axi_wstrb  ), // input wire [3 : 0] s_axi_wstrb
		.s_axi_wlast  (m00_axi_wlast  ), // input wire s_axi_wlast
		.s_axi_wvalid (m00_axi_wvalid ), // input wire s_axi_wvalid
		.s_axi_wready (m00_axi_wready ), // output wire s_axi_wready
		.s_axi_bid    (m00_axi_bid    ), // output wire [3 : 0] s_axi_bid
		.s_axi_bresp  (m00_axi_bresp  ), // output wire [1 : 0] s_axi_bresp
		.s_axi_bvalid (m00_axi_bvalid ), // output wire s_axi_bvalid
		.s_axi_bready (m00_axi_bready ), // input wire s_axi_bready
		.s_axi_arid   (m00_axi_arid   ), // input wire [3 : 0] s_axi_arid
		.s_axi_araddr (m00_axi_araddr ), // input wire [31 : 0] s_axi_araddr
		.s_axi_arlen  (m00_axi_arlen  ), // input wire [7 : 0] s_axi_arlen
		.s_axi_arsize (m00_axi_arsize ), // input wire [2 : 0] s_axi_arsize
		.s_axi_arburst(m00_axi_arburst), // input wire [1 : 0] s_axi_arburst
		.s_axi_arvalid(m00_axi_arvalid), // input wire s_axi_arvalid
		.s_axi_arready(m00_axi_arready), // output wire s_axi_arready
		.s_axi_rid    (m00_axi_rid    ), // output wire [3 : 0] s_axi_rid
		.s_axi_rdata  (m00_axi_rdata  ), // output wire [31 : 0] s_axi_rdata
		.s_axi_rresp  (m00_axi_rresp  ), // output wire [1 : 0] s_axi_rresp
		.s_axi_rlast  (m00_axi_rlast  ), // output wire s_axi_rlast
		.s_axi_rvalid (m00_axi_rvalid ), // output wire s_axi_rvalid
		.s_axi_rready (m00_axi_rready )  // input wire s_axi_rready
	);

	fifo_generator_0 fifo_generator_wr_i0 (
		.clk       (m00_axi_aclk    ), // input wire clk
		.srst      (~m00_axi_aresetn), // input wire srst
		.din       (rdfifo_wrdata   ), // input wire [31 : 0] din
		.wr_en     (rdfifo_wren     ), // input wire wr_en
		.rd_en     (fifo_rden       ), // input wire rd_en
		.dout      (fifo_rddata     ), // output wire [31 : 0] dout
		.full      (                ), // output wire full
		.empty     (fifo_empty      ), // output wire empty
		.prog_empty(fifo_prog_empty )  // output wire prog_empty
	);

	assign m00_axi_aclk = clk;
	assign m00_axi_aresetn = rstb;

	initial begin
		rdfifo_wren = '0;
		rdfifo_wrdata = '0;
		fifo_full = '0;
		fifo_prog_full = '0;
		// do something
		@(posedge m00_axi_aresetn)
		repeat(10)@(posedge m00_axi_aclk);
		repeat(50) begin
			@(posedge m00_axi_aclk)
			rdfifo_wren = 1'b1;
			rdfifo_wrdata = rdfifo_wrdata + 1;
		end
		@(posedge m00_axi_aclk)
		rdfifo_wren = 1'b0;
		#5000
		@(posedge m00_axi_aclk)
		$stop;
	end


endmodule
