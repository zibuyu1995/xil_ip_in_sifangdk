// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : oserdes_10to1_ddr.v
// Create : 2019-10-15 16:31:51
// Revised: 2019-11-05 10:25:33
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module oserdes_10to1_ddr(
		input clk,
		input clk_div,
		input rst,
		//
		input [9:0] data_in,
		//
		output pin_q
    );

	wire shift_out1;
	wire shift_out2;
	wire oserdes_q;

	OSERDESE2 #(
		.DATA_RATE_OQ  ("DDR"   ), // DDR, SDR
		.DATA_RATE_TQ  ("DDR"   ), // DDR, BUF, SDR
		.DATA_WIDTH    (10      ), // Parallel data width (2-8,10,14)
		.INIT_OQ       (1'b0    ), // Initial value of OQ output (1'b0,1'b1)
		.INIT_TQ       (1'b0    ), // Initial value of TQ output (1'b0,1'b1)
		.SERDES_MODE   ("MASTER"), // MASTER, SLAVE
		.SRVAL_OQ      (1'b0    ), // OQ output value when SR is used (1'b0,1'b1)
		.SRVAL_TQ      (1'b0    ), // TQ output value when SR is used (1'b0,1'b1)
		.TBYTE_CTL     ("FALSE" ), // Enable tristate byte operation (FALSE, TRUE)
		.TBYTE_SRC     ("FALSE" ), // Tristate byte source (FALSE, TRUE)
		.TRISTATE_WIDTH(1       )  // 3-state converter width (1,4)
	) oserdese2_mst_i0 (
		.OFB      (          ), // 1-bit output: Feedback path for data
		.OQ       (oserdes_q ), // 1-bit output: Data path output
		// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
		.SHIFTOUT1(          ),
		.SHIFTOUT2(          ),
		.TBYTEOUT (          ), // 1-bit output: Byte group tristate
		.TFB      (          ), // 1-bit output: 3-state control
		.TQ       (          ), // 1-bit output: 3-state control
		.CLK      (clk       ), // 1-bit input: High speed clock
		.CLKDIV   (clk_div   ), // 1-bit input: Divided clock
		// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
		.D1       (data_in[0]),
		.D2       (data_in[1]),
		.D3       (data_in[2]),
		.D4       (data_in[3]),
		.D5       (data_in[4]),
		.D6       (data_in[5]),
		.D7       (data_in[6]),
		.D8       (data_in[7]),
		.OCE      (1'b1      ), // 1-bit input: Output data clock enable
		.RST      (rst       ), // 1-bit input: Reset
		// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
		.SHIFTIN1 (shift_out1),
		.SHIFTIN2 (shift_out2),
		// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
		.T1       (1'b0      ),
		.T2       (1'b0      ),
		.T3       (1'b0      ),
		.T4       (1'b0      ),
		.TBYTEIN  (1'b0      ), // 1-bit input: Byte group tristate
		.TCE      (1'b0      )  // 1-bit input: 3-state clock enable
	);

	OSERDESE2 #(
		.DATA_RATE_OQ  ("DDR"  ), // DDR, SDR
		.DATA_RATE_TQ  ("DDR"  ), // DDR, BUF, SDR
		.DATA_WIDTH    (10     ), // Parallel data width (2-8,10,14)
		.INIT_OQ       (1'b0   ), // Initial value of OQ output (1'b0,1'b1)
		.INIT_TQ       (1'b0   ), // Initial value of TQ output (1'b0,1'b1)
		.SERDES_MODE   ("SLAVE"), // MASTER, SLAVE
		.SRVAL_OQ      (1'b0   ), // OQ output value when SR is used (1'b0,1'b1)
		.SRVAL_TQ      (1'b0   ), // TQ output value when SR is used (1'b0,1'b1)
		.TBYTE_CTL     ("FALSE"), // Enable tristate byte operation (FALSE, TRUE)
		.TBYTE_SRC     ("FALSE"), // Tristate byte source (FALSE, TRUE)
		.TRISTATE_WIDTH(1      )  // 3-state converter width (1,4)
	) oserdese2_slv_i0 (
		.OFB      (          ), // 1-bit output: Feedback path for data
		.OQ       (          ), // 1-bit output: Data path output
		// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
		.SHIFTOUT1(shift_out1),
		.SHIFTOUT2(shift_out2),
		.TBYTEOUT (          ), // 1-bit output: Byte group tristate
		.TFB      (          ), // 1-bit output: 3-state control
		.TQ       (          ), // 1-bit output: 3-state control
		.CLK      (clk       ), // 1-bit input: High speed clock
		.CLKDIV   (clk_div   ), // 1-bit input: Divided clock
		// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
		.D1       (1'b0      ),
		.D2       (1'b0      ),
		.D3       (data_in[8]),
		.D4       (data_in[9]),
		.D5       (1'b0      ),
		.D6       (1'b0      ),
		.D7       (1'b0      ),
		.D8       (1'b0      ),
		.OCE      (1'b1      ), // 1-bit input: Output data clock enable
		.RST      (rst       ), // 1-bit input: Reset
		// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
		.SHIFTIN1 (1'b0      ),
		.SHIFTIN2 (1'b0      ),
		// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
		.T1       (1'b0      ),
		.T2       (1'b0      ),
		.T3       (1'b0      ),
		.T4       (1'b0      ),
		.TBYTEIN  (1'b0      ), // 1-bit input: Byte group tristate
		.TCE      (1'b0      )  // 1-bit input: 3-state clock enable
	);

	OBUF obuf_ser_i0 (
		.O(pin_q    ), // Buffer output (connect directly to top-level port)
		.I(oserdes_q)  // Buffer input
	);

endmodule
