// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : timctrl_clock_gen.v
// Create : 2019-10-15 14:26:36
// Revised: 2019-10-15 14:37:20
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module timctrl_clock_gen#(
		parameter CLOCK_PERIOD = 10.000,
		parameter CLOCK_FBMULT = 10,
		parameter CLOCK_DIV = 10,
		parameter CLOCK_LINEDIV = 2
	)(
		input clk,
		input rst,
		//
		output clk_100m,
		output clk_500m,
		output locked
    );

    wire clk_fbout;
    wire clk_fbout_bufg;

    wire clk_out0;
    wire clk_out1;

	PLLE2_BASE #(
		.BANDWIDTH         ("OPTIMIZED"  ), // OPTIMIZED, HIGH, LOW
		.CLKFBOUT_MULT     (CLOCK_FBMULT ), // Multiply value for all CLKOUT, (2-64)
		.CLKFBOUT_PHASE    (0.0          ), // Phase offset in degrees of CLKFB, (-360.000-360.000).
		.CLKIN1_PERIOD     (CLOCK_PERIOD ), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		// CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
		.CLKOUT0_DIVIDE    (CLOCK_DIV    ),
		.CLKOUT1_DIVIDE    (CLOCK_LINEDIV),
		// CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
		.CLKOUT0_DUTY_CYCLE(0.5          ),
		.CLKOUT1_DUTY_CYCLE(0.5          ),
		// CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
		.CLKOUT0_PHASE     (0.0          ),
		.CLKOUT1_PHASE     (0.0          ),
		.DIVCLK_DIVIDE     (1            ), // Master division value, (1-56)
		.REF_JITTER1       (0.0          ), // Reference input jitter in UI, (0.000-0.999).
		.STARTUP_WAIT      ("FALSE"      )  // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
	) PLLE2_BASE_inst (
		// Clock Outputs: 1-bit (each) output: User configurable clock outputs
		.CLKOUT0 (clk_out0      ), // 1-bit output: CLKOUT0
		.CLKOUT1 (clk_out1      ), // 1-bit output: CLKOUT1
		.CLKOUT2 (              ), // 1-bit output: CLKOUT2
		.CLKOUT3 (              ), // 1-bit output: CLKOUT3
		.CLKOUT4 (              ), // 1-bit output: CLKOUT4
		.CLKOUT5 (              ), // 1-bit output: CLKOUT5
		// Feedback Clocks: 1-bit (each) output: Clock feedback ports
		.CLKFBOUT(clk_fbout     ), // 1-bit output: Feedback clock
		.LOCKED  (locked        ), // 1-bit output: LOCK
		.CLKIN1  (clk           ), // 1-bit input: Input clock
		// Control Ports: 1-bit (each) input: PLL control ports
		.PWRDWN  (1'b0          ), // 1-bit input: Power-down
		.RST     (rst           ), // 1-bit input: Reset
		// Feedback Clocks: 1-bit (each) input: Clock feedback ports
		.CLKFBIN (clk_fbout_bufg)  // 1-bit input: Feedback clock
	);

	BUFG bufg_clkfb_i0 (
		.O(clk_fbout_bufg), // 1-bit output: Clock output
		.I(clk_fbout)  // 1-bit input: Clock input
	);

	BUFG bufg_clkout0_i0 (
		.O(clk_100m), // 1-bit output: Clock output
		.I(clk_out0)  // 1-bit input: Clock input
	);

	BUFG bufg_clkout1_i0 (
		.O(clk_500m), // 1-bit output: Clock output
		.I(clk_out1)  // 1-bit input: Clock input
	);


endmodule
