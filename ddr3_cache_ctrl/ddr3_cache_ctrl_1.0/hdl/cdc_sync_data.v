// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cdc_sync_data.v
// Create : 2019-03-28 13:55:30
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

	module cdc_sync_data #(
		parameter NUM_OF_BITS = 1, //max width 72
		parameter ASYNC_CLK   = 1
	)(
		input                        in_clk  ,
		input      [NUM_OF_BITS-1:0] in_data ,
		input                        out_clk ,
		output     [NUM_OF_BITS-1:0] out_data
	);

		reg [3:0] rst_n = 4'b1111;
		always @ (posedge out_clk) begin
			rst_n <= {rst_n[2:0], 1'b0};
		end

		generate
			if ((ASYNC_CLK == 1)&&(NUM_OF_BITS<=36)) begin
				FIFO_DUALCLOCK_MACRO #(
					.ALMOST_EMPTY_OFFSET    (9'h080     ), // Sets the almost empty threshold
					.ALMOST_FULL_OFFSET     (9'h080     ), // Sets almost full threshold
					.DATA_WIDTH             (NUM_OF_BITS), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
					.DEVICE                 ("7SERIES"  ), // Target device: "7SERIES"
					.FIFO_SIZE              ("18Kb"     ), // Target BRAM: "18Kb" or "36Kb"
					.FIRST_WORD_FALL_THROUGH("TRUE"     )  // Sets the FIFO FWFT to "TRUE" or "FALSE"
				) FIFO_DUALCLOCK_MACRO_cdc_inst (
					.ALMOSTEMPTY(        ), // 1-bit output almost empty
					.ALMOSTFULL (        ), // 1-bit output almost full
					.DO         (out_data), // Output data, width defined by DATA_WIDTH parameter
					.EMPTY      (        ), // 1-bit output empty
					.FULL       (        ), // 1-bit output full
					.RDCOUNT    (        ), // Output read count, width determined by FIFO depth
					.RDERR      (        ), // 1-bit output read error
					.WRCOUNT    (        ), // Output write count, width determined by FIFO depth
					.WRERR      (        ), // 1-bit output write error
					.DI         (in_data ), // Input data, width defined by DATA_WIDTH parameter
					.RDCLK      (out_clk ), // 1-bit input read clock
					.RDEN       (1'b1    ), // 1-bit input read enable
					.RST        (rst_n[3]), // 1-bit input reset
					.WRCLK      (in_clk  ), // 1-bit input write clock
					.WREN       (1'b1    )  // 1-bit input write enable
				);

			end else if((ASYNC_CLK == 1)&&(NUM_OF_BITS>36))
				FIFO_DUALCLOCK_MACRO #(
					.ALMOST_EMPTY_OFFSET    (9'h080     ), // Sets the almost empty threshold
					.ALMOST_FULL_OFFSET     (9'h080     ), // Sets almost full threshold
					.DATA_WIDTH             (NUM_OF_BITS), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
					.DEVICE                 ("7SERIES"  ), // Target device: "7SERIES"
					.FIFO_SIZE              ("36Kb"     ), // Target BRAM: "18Kb" or "36Kb"
					.FIRST_WORD_FALL_THROUGH("TRUE"     )  // Sets the FIFO FWFT to "TRUE" or "FALSE"
				) FIFO_DUALCLOCK_MACRO_cdc_inst (
					.ALMOSTEMPTY(        ), // 1-bit output almost empty
					.ALMOSTFULL (        ), // 1-bit output almost full
					.DO         (out_data), // Output data, width defined by DATA_WIDTH parameter
					.EMPTY      (        ), // 1-bit output empty
					.FULL       (        ), // 1-bit output full
					.RDCOUNT    (        ), // Output read count, width determined by FIFO depth
					.RDERR      (        ), // 1-bit output read error
					.WRCOUNT    (        ), // Output write count, width determined by FIFO depth
					.WRERR      (        ), // 1-bit output write error
					.DI         (in_data ), // Input data, width defined by DATA_WIDTH parameter
					.RDCLK      (out_clk ), // 1-bit input read clock
					.RDEN       (1'b1    ), // 1-bit input read enable
					.RST        (rst_n[3]), // 1-bit input reset
					.WRCLK      (in_clk  ), // 1-bit input write clock
					.WREN       (1'b1    )  // 1-bit input write enable
				);
			else begin
				// always @(*) begin
				// 	out_data <= in_data;
				// end
				assign out_data = in_data;
			end
		endgenerate

	endmodule
