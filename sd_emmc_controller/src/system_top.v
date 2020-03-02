// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : system_top.v
// Create : 2019-12-23 09:37:20
// Revised: 2019-12-26 09:34:13
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module system_top(
		input pl_clk,
		//
		input emmc1_ds,
		inout [7:0] emmc1_data,
		inout emmc1_cmd,
		output emmc1_clk,
		// zynq
		inout [14:0]DDR_addr,
		inout [2:0]DDR_ba,
		inout DDR_cas_n,
		inout DDR_ck_n,
		inout DDR_ck_p,
		inout DDR_cke,
		inout DDR_cs_n,
		inout [3:0]DDR_dm,
		inout [31:0]DDR_dq,
		inout [3:0]DDR_dqs_n,
		inout [3:0]DDR_dqs_p,
		inout DDR_odt,
		inout DDR_ras_n,
		inout DDR_reset_n,
		inout DDR_we_n,
		inout FIXED_IO_ddr_vrn,
		inout FIXED_IO_ddr_vrp,
		inout [53:0]FIXED_IO_mio,
		inout FIXED_IO_ps_clk,
		inout FIXED_IO_ps_porb,
		inout FIXED_IO_ps_srstb
    );

	localparam IODELAY_GROUP = "dev_if_delay_group";

	wire clk_200m;
	wire clk_200m_90;
	wire glbl_rst_n;

	wire clk_div;
	wire clk_div_90;
	wire clk_div_locked;
	wire [15:0] divisor;

	wire idly_locked;

	wire sel_clk;
	wire sd_clk;
	wire sd_clk_90;
	reg sd_rst = 1;

	wire [1:0] setting_init;
	wire [39:0] cmd_init;
	wire start_xfr_init;

	wire [1:0] setting_user;
	wire [39:0] cmd_user;
	wire start_xfr_user;

	wire [1:0] sel_mux;

	wire [1:0] setting_i;
	wire [39:0] cmd_i;
	wire start_i;
	wire cmd_dat_i;
	wire [119:0] response_o;
	wire finish_o;
	wire crc_ok_o;
	wire index_ok_o;
	wire cmd_oe_o;
	wire cmd_out_o;

	wire [15:0] data_out;
	wire data_t;
	wire [15:0] data_in;

	wire init_done;
	wire init_failed;
	wire start_init;

	wire [1:0] sd_setting;
	wire [39:0] sd_command;
	wire sd_xfr;

	wire [5:0] int_status_o;
	wire [31:0] response_0_o;
	wire [31:0] response_1_o;
	wire [31:0] response_2_o;
	wire [31:0] response_3_o;

	wire [11:0] blksize;
	wire [31:0] data_out_o;
	wire we;
	wire bus_4bit;
	wire bus_8bit;
	wire [15:0] blkcnt;
	wire [1:0] dat_start;
	wire dat_busy;
	wire dat_crc_ok;
	wire read_trans_active;
	wire write_trans_active;
	wire [2:0] UHSMode;
	wire start_write;

	wire [63:0] tied_to_gnd;
	wire [63:0] tied_to_vcc;

	assign tied_to_gnd = 64'h0;
	assign tied_to_vcc = 64'hffff_ffff_ffff_ffff;

	system_bd_wrapper system_bd_wrapper_i0 (
		.DDR_addr          (DDR_addr),
		.DDR_ba            (DDR_ba),
		.DDR_cas_n         (DDR_cas_n),
		.DDR_ck_n          (DDR_ck_n),
		.DDR_ck_p          (DDR_ck_p),
		.DDR_cke           (DDR_cke),
		.DDR_cs_n          (DDR_cs_n),
		.DDR_dm            (DDR_dm),
		.DDR_dq            (DDR_dq),
		.DDR_dqs_n         (DDR_dqs_n),
		.DDR_dqs_p         (DDR_dqs_p),
		.DDR_odt           (DDR_odt),
		.DDR_ras_n         (DDR_ras_n),
		.DDR_reset_n       (DDR_reset_n),
		.DDR_we_n          (DDR_we_n),
		.FIXED_IO_ddr_vrn  (FIXED_IO_ddr_vrn),
		.FIXED_IO_ddr_vrp  (FIXED_IO_ddr_vrp),
		.FIXED_IO_mio      (FIXED_IO_mio),
		.FIXED_IO_ps_clk   (FIXED_IO_ps_clk),
		.FIXED_IO_ps_porb  (FIXED_IO_ps_porb),
		.FIXED_IO_ps_srstb (FIXED_IO_ps_srstb),
		.clk_200m          (clk_200m),
		.clk_200m_90       (clk_200m_90),
		.glbl_rst_n        (glbl_rst_n),
		.pl_clk            (pl_clk)
	);

	// clk_wiz_0 clk_wiz_0_i0 (.clk_out1(clk_200m), .clk_out2(clk_200m_90), .locked(glbl_rst_n), .clk_in1(pl_clk));


	sd_emmc_clock_divider sd_emmc_clock_divider_i0 (
		.clk          (clk_200m      ),
		.rst_n        (glbl_rst_n    ),
		.divisor      (divisor       ),
		.sd_clk_div   (clk_div       ),
		.sd_clk_div_90(clk_div_90    ),
		.locked       (clk_div_locked)
	);

	BUFGMUX BUFGMUX_i0 (
		.O (sd_clk  ), // 1-bit output: Clock output
		.I0(clk_200m), // 1-bit input: Clock input (S=0)
		.I1(clk_div ), // 1-bit input: Clock input (S=1)
		.S (sel_clk )  // 1-bit input: Clock select
	);

	BUFGMUX BUFGMUX_i1 (
		.O (sd_clk_90  ), // 1-bit output: Clock output
		.I0(clk_200m_90), // 1-bit input: Clock input (S=0)
		.I1(clk_div_90 ), // 1-bit input: Clock input (S=1)
		.S (sel_clk    )  // 1-bit input: Clock select
	);
	// assign sd_clk_90 = (sel_clk==1'b1)?clk_div_90:clk_200m_90;

	(* IODELAY_GROUP = IODELAY_GROUP *) 
	IDELAYCTRL IDELAYCTRL_i0 (
		.RDY   (idly_locked),
		.REFCLK(clk_200m   ),
		.RST   (~glbl_rst_n)
	);
	// assign idly_locked = 1'b1;

	always @ (posedge sd_clk)
		sd_rst <= (sel_clk==1)?(~clk_div_locked):(~glbl_rst_n);

	emmc_init emmc_init_i0 (
		.sd_clk      (sd_clk),
		.sd_rst_n    (~sd_rst),
		.setting_o   (setting_init),
		.cmd_o       (cmd_init),
		.start_xfr_o (start_xfr_init),
		.response_i  (response_o),
		.crc_ok_i    (crc_ok_o),
		.index_ok_i  (index_ok_o),
		.finish_i    (finish_o),
		.busy_i      (data_in[0]),
		.start_init  (start_init),
		.init_failed (init_failed),
		.init_done   (init_done)
	);

	sd_emmc_user sd_emmc_user_i0(
		.sd_clk         (sd_clk),
		.rst            (sd_rst),
		.int_status_rst (1'b0),
		.setting_i      (sd_setting),
		.cmd_i          (sd_command),
		.start_xfr_i    (sd_xfr),
		.busy_check_i   (1'b0),
		.setting_o      (setting_user),
		.cmd_o          (cmd_user),
		.start_xfr_o    (start_xfr_user),
		.response_i     (response_o),
		.crc_ok_i       (crc_ok_o),
		.index_ok_i     (index_ok_o),
		.finish_i       (finish_o),
		.busy_i         (data_in[0]),
		.int_status_o   (int_status_o),
		.response_0_o   (response_0_o),
		.response_1_o   (response_1_o),
		.response_2_o   (response_2_o),
		.response_3_o   (response_3_o)
	);


	sd_emmc_cmd_mux sd_emmc_cmd_mux_i0 (
		.sd_clk      (sd_clk),
		.rst         (sd_rst),
		.sel_mux     (sel_mux),
		// sd_emmc init
		.setting_0   (setting_init),
		.cmd_0       (cmd_init),
		.start_xfr_0 (start_xfr_init),
		// sd_emmc negotiated speed & line width
		.setting_1   (tied_to_gnd[1:0]),
		.cmd_1       (tied_to_gnd[39:0]),
		.start_xfr_1 (tied_to_gnd[0]),
		// sd_emmc auto transfer mode
		.setting_2   (tied_to_gnd[1:0]),
		.cmd_2       (tied_to_gnd[39:0]),
		.start_xfr_2 (tied_to_gnd[0]),
		// sd_emmc user cmd mode
		.setting_3   (setting_user),
		.cmd_3       (cmd_user),
		.start_xfr_3 (start_xfr_user),
		// sd_emmc cmd out
		.setting_o   (setting_i),
		.cmd_o       (cmd_i),
		.start_xfr_o (start_i)
	);


	sd_emmc_cmd_serial_host sd_emmc_cmd_serial_host_i0 (
		.sd_clk              (sd_clk),
		.rst                 (sd_rst),
		.setting_i           (setting_i),
		.cmd_i               (cmd_i),
		.start_i             (start_i),
		.response_o          (response_o),
		.crc_ok_o            (crc_ok_o),
		.index_ok_o          (index_ok_o),
		.finish_o            (finish_o),
		.cmd_dat_i           (cmd_dat_i),
		.cmd_out_o           (cmd_out_o),
		.cmd_oe_o            (cmd_oe_o),
		.command_inhibit_cmd (command_inhibit_cmd)
	);

	sd_emmc_data_serial_host sd_emmc_data_serial_host_i0 (
		.sd_clk             (sd_clk),
		.rst                (sd_rst),
		.data_in            (32'h8023),
		.rd                 (),
		.data_out_o         (data_out_o),
		.we                 (we),
		.DAT_oe_o           (data_t),
		.DAT_dat_o          (data_out),
		.DAT_dat_i          (data_in),
		.blksize            (blksize),
		.bus_4bit           (bus_4bit),
		.bus_8bit           (bus_8bit),
		.blkcnt             (blkcnt),
		.start              (dat_start),
		.busy               (dat_busy),
		.crc_ok             (dat_crc_ok),
		.read_trans_active  (read_trans_active),
		.write_trans_active (write_trans_active),
		.start_write        (start_write),
		.write_next_block   (write_next_block),
		.UHSMode            (UHSMode)
	);



	sd_emmc_phy #(
		.IODELAY_GROUP(IODELAY_GROUP)
	) sd_emmc_phy_i0 (
		.sd_clk             (sd_clk),
		.sd_clk_90          (sd_clk_90),
		.rst                (sd_rst),
		.idly_tuning_start  (1'b0),
		.idly_tuning_ready  (),
		.idly_tuning_done   (),
		.idly_tuning_failed (),
		.timeout_delay      (24'd0),
		.cmd_out            (cmd_out_o),
		.cmd_t              (cmd_oe_o),
		.cmd_in             (cmd_dat_i),
		.data_out           (data_out),
		.data_t             (data_t),
		.data_in            (data_in),
		.sd_clk_pad         (emmc1_clk),
		.sd_cmd_pad         (emmc1_cmd),
		.sd_data_pad        (emmc1_data),
		.sd_ds_pad          (emmc1_ds)
	);

	// debug
	vio_0 vio_0_i0 (
		.clk       (clk_200m  ), // input wire clk
		.probe_in0 (glbl_rst_n), // input wire [0 : 0] probe_in0
		.probe_in1 (sd_rst    ), // input wire [0 : 0] probe_in1
		.probe_out0(divisor   ), // output wire [15 : 0] probe_out0
		.probe_out1(sel_clk   )  // output wire [0 : 0] probe_out1
	);

	vio_3 vio_3_i0 (
		.clk       (clk_200m   ), // input wire clk
		.probe_in0 (init_done  ), // input wire [0 : 0] probe_in0
		.probe_in1 (init_failed), // input wire [0 : 0] probe_in1
		.probe_in2 (idly_locked), // input wire [0 : 0] probe_in2
		.probe_out0(start_init )  // output wire [0 : 0] probe_out0
	);

	vio_4 vio_4_i0 (
		.clk       (clk_200m    ), // input wire clk
		.probe_in0 (int_status_o), // input wire [5 : 0] probe_in0
		.probe_in1 (response_0_o), // input wire [31 : 0] probe_in1
		.probe_in2 (response_1_o), // input wire [31 : 0] probe_in2
		.probe_in3 (response_2_o), // input wire [31 : 0] probe_in3
		.probe_in4 (response_3_o), // input wire [31 : 0] probe_in4
		.probe_out0(sel_mux     ), // output wire [1 : 0] probe_out0
		.probe_out1(sd_setting  ), // output wire [1 : 0] probe_out1
		.probe_out2(sd_command  ), // output wire [39 : 0] probe_out2
		.probe_out3(sd_xfr      )  // output wire [0 : 0] probe_out3
	);

	vio_5 vio_5_i0 (
		.clk       (clk_200m          ), // input wire clk
		.probe_in0 (dat_busy          ), // input wire [0 : 0] probe_in0
		.probe_in1 (dat_crc_ok        ), // input wire [0 : 0] probe_in1
		.probe_in2 (read_trans_active ), // input wire [0 : 0] probe_in2
		.probe_in3 (write_trans_active), // input wire [0 : 0] probe_in3
		.probe_out0(blksize           ), // output wire [11 : 0] probe_out0
		.probe_out1(bus_4bit          ), // output wire [0 : 0] probe_out1
		.probe_out2(bus_8bit          ), // output wire [0 : 0] probe_out2
		.probe_out3(blkcnt            ), // output wire [15 : 0] probe_out3
		.probe_out4(dat_start         ), // output wire [1 : 0] probe_out4
		.probe_out5(UHSMode           ), // output wire [2 : 0] probe_out5
		.probe_out6(start_write       )  // output wire [0 : 0] probe_out6
	);

	ila_1 ila_1_i0 (
		.clk(clk_200m), // input wire clk
		.probe0(clk_div), // input wire [0:0]  probe0  
		.probe1(setting_i), // input wire [1:0]  probe1 
		.probe2(cmd_i), // input wire [39:0]  probe2 
		.probe3(start_i), // input wire [0:0]  probe3 
		.probe4(cmd_out_o), // input wire [0:0]  probe4 
		.probe5(cmd_oe_o), // input wire [0:0]  probe5 
		.probe6(cmd_dat_i), // input wire [0:0]  probe6 
		.probe7(data_in) // input wire [15:0]  probe7
	);

	ila_2 ila_2_i0 (
		.clk   (clk_200m  ), // input wire clk
		.probe0(clk_div   ), // input wire [0:0]  probe0
		.probe1(data_out_o), // input wire [31:0]  probe1
		.probe2(we        )  // input wire [0:0]  probe2
	);


endmodule
