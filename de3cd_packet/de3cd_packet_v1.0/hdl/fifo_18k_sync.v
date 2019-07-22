// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : fifo_18k_sync.v
// Create : 2019-07-18 15:24:38
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module fifo_18k_sync(
		input clk,    // Clock
		input rst,  // Synchronous reset active high
		// 
		input wren,
		input [15:0] wrdata,
		output wrfull,
		//
		input rden,
		output [15:0] rddata,
		output rdempty
	);
	
	wire [31:0] rddata_w;
	reg [5:0] rst_r = 0;
	wire real_rst;

	always @ (posedge clk)
		rst_r <= {rst_r[4:0], rst};

	assign real_rst = |rst_r;

	FIFO18E1 #(
		.ALMOST_EMPTY_OFFSET    (13'h0080     ), // Sets the almost empty threshold
		.ALMOST_FULL_OFFSET     (13'h0080     ), // Sets almost full threshold
		.DATA_WIDTH             (18           ), // Sets data width to 4-36
		.DO_REG                 (1            ), // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
		.EN_SYN                 ("FALSE"      ), // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
		.FIFO_MODE              ("FIFO18"     ), // Sets mode to FIFO18 or FIFO18_36
		.FIRST_WORD_FALL_THROUGH("TRUE"       ), // Sets the FIFO FWFT to FALSE, TRUE
		.INIT                   (36'h000000000), // Initial values on output port
		.SIM_DEVICE             ("7SERIES"    ), // Must be set to "7SERIES" for simulation behavior
		.SRVAL                  (36'h000000000)  // Set/Reset value for output port
	) FIFO18E1_i0 (
		// Read Data: 32-bit (each) output: Read output data
		.DO         (rddata_w       ), // 32-bit output: Data output
		.DOP        (               ), // 4-bit output: Parity data output
		// Status: 1-bit (each) output: Flags and other FIFO status outputs
		.ALMOSTEMPTY(               ), // 1-bit output: Almost empty flag
		.ALMOSTFULL (               ), // 1-bit output: Almost full flag
		.EMPTY      (rdempty        ), // 1-bit output: Empty flag
		.FULL       (wrfull         ), // 1-bit output: Full flag
		.RDCOUNT    (               ), // 12-bit output: Read count
		.RDERR      (               ), // 1-bit output: Read error
		.WRCOUNT    (               ), // 12-bit output: Write count
		.WRERR      (               ), // 1-bit output: Write error
		// Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
		.RDCLK      (clk            ), // 1-bit input: Read clock
		.RDEN       (rden           ), // 1-bit input: Read enable
		.REGCE      (1'b1           ), // 1-bit input: Clock enable
		.RST        (real_rst       ), // 1-bit input: Asynchronous Reset
		.RSTREG     (real_rst       ), // 1-bit input: Output register set/reset
		// Write Control Signals: 1-bit (each) input: Write clock and enable input signals
		.WRCLK      (clk            ), // 1-bit input: Write clock
		.WREN       (wren           ), // 1-bit input: Write enable
		// Write Data: 32-bit (each) input: Write input data
		.DI         ({16'd0, wrdata}), // 32-bit input: Data input
		.DIP        (4'd0           )  // 4-bit input: Parity input
	);

	assign rddata = rddata_w[15:0];


endmodule