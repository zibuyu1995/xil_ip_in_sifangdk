// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_timing_ctrl.v
// Create : 2019-10-15 10:58:28
// Revised: 2019-11-04 17:47:42
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cmlk_timing_ctrl#(
		parameter CLOCK_PERIOD = 10.000,
		parameter CLOCK_FBMULT = 10,
		parameter CLOCK_DIV = 10
	)(
		// clock & reset
		input clk,
		input rst_n,
		// input parameter
		input [15:0] cmos_freq,
		input [15:0] cmos_width,
		input [31:0] laser_freq,
		input [31:0] laser_width,
		input [31:0] frame_gate_width_a,
		input [31:0] frame_gate_delay_a,
		input [31:0] frame_gate_width_b,
		input [31:0] frame_gate_delay_b,
		input [7:0] tim_cycles_m,
		input [7:0] delay_step_delta_t,
		input [15:0] bg_frame_deci_n,

		input       load_param,

		// output indcator
		output [1:0] frame_type, // 01--- frame A, 10--- frame B, 00--- background frame
		output clock_locked,

		// output pulse
		output cmos_trig_pulse,
		output laser_pulse,
		output gate_pulse
	);

	localparam CLOCK_LINEDIV = CLOCK_DIV / 5;

	wire clk_100m;
	wire clk_500m;
	wire pll_locked;

	wire [15:0] cmos_freq_w;
	wire [15:0] cmos_width_w;
	wire [31:0] laser_freq_w;
	wire [31:0] laser_width_w;
	wire [31:0] frame_gate_width_a_w;
	wire [31:0] frame_gate_delay_a_w;
	wire [31:0] frame_gate_width_b_w;
	wire [31:0] frame_gate_delay_b_w;
	wire [7:0] tim_cycles_m_w;
	wire [7:0] delay_step_delta_t_w;
	wire [15:0] bg_frame_deci_n_w;

	wire cmos_trig_pulse_w;

	wire [31:0] cnt_w;
	wire [1:0] frame_type_w;

	wire [9:0] laser_data_out;
	wire [9:0] gate_data_out;

	// clock generator
	timctrl_clock_gen #(
		.CLOCK_PERIOD(CLOCK_PERIOD),
		.CLOCK_FBMULT(CLOCK_FBMULT),
		.CLOCK_DIV(CLOCK_DIV),
		.CLOCK_LINEDIV(CLOCK_LINEDIV)
	) timctrl_clock_gen_i0 (
		.clk      (clk),
		.rst      (~rst_n),
		.clk_100m (clk_100m),
		.clk_500m (clk_500m),
		.locked   (pll_locked)
	);

	assign clock_locked = pll_locked;

	// parameter load
	param_assert param_assert_i0(
		.clk                  (clk_100m),
		.rst_n                (pll_locked),
		.cmos_freq            (cmos_freq),
		.cmos_width           (cmos_width),
		.laser_freq           (laser_freq),
		.laser_width          (laser_width),
		.frame_gate_width_a   (frame_gate_width_a),
		.frame_gate_delay_a   (frame_gate_delay_a),
		.frame_gate_width_b   (frame_gate_width_b),
		.frame_gate_delay_b   (frame_gate_delay_b),
		.tim_cycles_m         (tim_cycles_m),
		.delay_step_delta_t   (delay_step_delta_t),
		.bg_frame_deci_n      (bg_frame_deci_n),
		.load_param           (load_param),
		.cmos_freq_o          (cmos_freq_w),
		.cmos_width_o         (cmos_width_w),
		.laser_freq_o         (laser_freq_w),
		.laser_width_o        (laser_width_w),
		.frame_gate_width_a_o (frame_gate_width_a_w),
		.frame_gate_delay_a_o (frame_gate_delay_a_w),
		.frame_gate_width_b_o (frame_gate_width_b_w),
		.frame_gate_delay_b_o (frame_gate_delay_b_w),
		.tim_cycles_m_o       (tim_cycles_m_w),
		.delay_step_delta_t_o (delay_step_delta_t_w),
		.bg_frame_deci_n_o    (bg_frame_deci_n_w)
	);


	cmos_trig_gen cmos_trig_gen_i0(
		.clk              (clk_100m),
		.rst_n            (pll_locked),
		.cmos_trig_period (cmos_freq_w),
		.cmos_trig_width  (cmos_width_w),
		.cmos_trig_pulse  (cmos_trig_pulse_w)
	);

	pulse_counter_gen pulse_counter_gen_i0(
		.clk             (clk_100m),
		.rst_n           (pll_locked),
		.laser_freq      (laser_freq_w),
		.cmos_trig_pulse (cmos_trig_pulse_w),
		.bg_frame_deci_n (bg_frame_deci_n_w),
		.cnt_out         (cnt_w),
		.frame_type      (frame_type_w)
	);

	laser_pulse_gen laser_pulse_gen_i0(
		.clk            (clk_100m),
		.rst_n          (pll_locked),
		.laser_cnt_in   (cnt_w),
		.laser_width    (laser_width_w),
		.frame_type     (frame_type_w),
		.laser_data_out (laser_data_out)
	);

	gate_pulse_gen gate_pulse_gen_i0(
		.clk                (clk_100m),
		.rst_n              (pll_locked),
		.laser_cnt_in       (cnt_w),
		.laser_freq         (laser_freq_w),
		.frame_gate_width_a (frame_gate_width_a_w),
		.frame_gate_delay_a (frame_gate_delay_a_w),
		.frame_gate_width_b (frame_gate_width_b_w),
		.frame_gate_delay_b (frame_gate_delay_b_w),
		.tim_cycles_m       (tim_cycles_m_w),
		.delay_step_delta_t (delay_step_delta_t_w),
		.frame_type         (frame_type_w),
		.gate_data_out      (gate_data_out)
	);

	shift_reg #(.PLACE_IN_IOB("true"), .DELAY_CYCLE (56)) shift_reg_i0(.clk(clk_100m), .rst_n(pll_locked), .din(cmos_trig_pulse_w), .dout(cmos_trig_pulse));
	oserdes_10to1_ddr oserdes_10to1_ddr_i0(.clk(clk_500m), .clk_div(clk_100m), .rst(~pll_locked), .data_in(laser_data_out), .pin_q(laser_pulse));
	oserdes_10to1_ddr oserdes_10to1_ddr_i1(.clk(clk_500m), .clk_div(clk_100m), .rst(~pll_locked), .data_in(gate_data_out), .pin_q(gate_pulse));
	assign frame_type = frame_type_w;

endmodule
