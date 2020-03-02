// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_phy.v
// Create : 2019-11-29 15:48:36
// Revised: 2020-03-02 14:53:31
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_phy#(
		parameter IODELAY_GROUP = "dev_if_delay_group"
	)(
		input sd_clk,
		input sd_clk_90,
		input rst,
		// control interface (TODO)
		input idly_tuning_start,
		output idly_tuning_ready,
		output idly_tuning_done,
		output idly_tuning_failed,
		input [23:0] timeout_delay,
		// data slave interface 
		input cmd_out,
		input cmd_t,
		output cmd_in,
		input [15:0] data_out, // [7:0] ddr positive edge, [15:8] ddr negetive edge
		input data_t,
		output [15:0] data_in,
		// sd/emmc io pad
		output sd_clk_pad,
		inout sd_cmd_pad,
		inout [7:0] sd_data_pad, 
		input sd_ds_pad		// data strobe (only HS400)
    );

	// wire & reg description
	wire sd_clk_90_s;
	wire cmd_out_s;
	wire cmd_t_s;
	wire cmd_t_n;
	wire cmd_in_s;

	wire [7:0] data_in_s;
	wire [7:0] data_in_idly;
	wire [7:0] data_out_s;
	wire [7:0] data_t_s;
	wire data_t_n;

	wire ds_in_s;
	wire ds_in_idly;
	(* MARK_DEBUG="true" *)wire [1:0] ds_in_iddr;

	wire [4:0] cntval_in;
	wire cntval_load;
	wire [4:0] cntval_out;

	//---------------------- sd_emmc clock line ----------------------
	sd_emmc_oddr #(
		.DATA_WIDTH  (1          ),
		.DDR_CLK_EDGE("SAME_EDGE")
	) sd_emmc_oddr_sdclk_i (
		.clk (sd_clk_90  ),
		.rst (1'b0       ),
		.din (2'b01      ),
		.dout(sd_clk_90_s)
	);

	//---------------------- command line ----------------------
	sd_emmc_reg #(
		.DATA_WIDTH  (1     ),
		.PLACE_IN_IOB("TRUE")
	) sd_emmc_reg_cmdout_i (
		.clk (sd_clk   ),
		.rst (rst      ),
		.din (cmd_out  ),
		.dout(cmd_out_s)
	);
	
	sd_emmc_reg #(
		.DATA_WIDTH  (1     ),
		.PLACE_IN_IOB("TRUE")
	) sd_emmc_reg_cmdt_i (
		.clk (sd_clk ),
		.rst (rst    ),
		.din (cmd_t  ),
		.dout(cmd_t_s)
	);

	// sd_emmc_reg #(
	// 	.DATA_WIDTH  (1      ),
	// 	.PLACE_IN_IOB("FALSE")
	// ) sd_emmc_reg_cmdt_i1 (
	// 	.clk (sd_clk ),
	// 	.rst (rst    ),
	// 	.din (~cmd_t ),
	// 	.dout(cmd_t_n)
	// );

	sd_emmc_reg #(
		.DATA_WIDTH  (1     ),
		.PLACE_IN_IOB("TRUE")
	) sd_emmc_reg_cmdin_i (
		.clk (sd_clk  ),
		.rst (rst     ),
		.din (cmd_in_s),
		.dout(cmd_in  )
	);

	//--------------------- data line ----------------------
	sd_emmc_idelay #(
		.DATA_WIDTH   (8            ),
		.IODELAY_GROUP(IODELAY_GROUP)
	) sd_emmc_idelay_dat_i (
		.clk        (sd_clk        ),
		.rst        (rst           ),
		.cntval_in  ({8{cntval_in}}),
		.cntval_load(cntval_load   ),
		.cntval_out (              ),
		.din_ibuf   (data_in_s     ),
		.din_idelay (data_in_idly  )
	);

	sd_emmc_iddr #(
		.DATA_WIDTH  (8          ),
		.DDR_CLK_EDGE("SAME_EDGE")
	) sd_emmc_iddr_dat_i (
		.clk (sd_clk      ),
		.rst (rst         ),
		.din (data_in_idly),
		.dout(data_in     )
	);

	sd_emmc_oddr #(
		.DATA_WIDTH  (8          ),
		.DDR_CLK_EDGE("SAME_EDGE")
	) sd_emmc_oddr_dat_i (
		.clk (sd_clk    ),
		.rst (rst       ),
		.din (data_out  ),
		.dout(data_out_s)
	);

	sd_emmc_oddr #(
		.DATA_WIDTH  (8          ),
		.DDR_CLK_EDGE("SAME_EDGE")
	) sd_emmc_oddr_datt_i (
		.clk (sd_clk      ),
		.rst (rst         ),
		.din ({16{data_t}}),
		.dout(data_t_s    )
	);

	// sd_emmc_reg #(
	// 	.DATA_WIDTH  (1      ),
	// 	.PLACE_IN_IOB("FALSE")
	// ) sd_emmc_reg_datt_i (
	// 	.clk (sd_clk  ),
	// 	.rst (rst     ),
	// 	.din (~data_t ),
	// 	.dout(data_t_n)
	// );

	//--------------------- data strobe line ----------------------
	sd_emmc_idelay #(
		.DATA_WIDTH   (1            ),
		.IODELAY_GROUP(IODELAY_GROUP)
	) sd_emmc_idelay_ds_i (
		.clk        (sd_clk     ),
		.rst        (rst        ),
		.cntval_in  (cntval_in  ),
		.cntval_load(cntval_load),
		.cntval_out (cntval_out ),
		.din_ibuf   (ds_in_s    ),
		.din_idelay (ds_in_idly )
	);

	sd_emmc_iddr #(
		.DATA_WIDTH  (1                    ),
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
	) sd_emmc_iddr_ds_i (
		.clk (sd_clk    ),
		.rst (rst       ),
		.din (ds_in_idly),
		.dout(ds_in_iddr)
	);

	//--------------------- hs400 auto tuning inst ----------------------
	hs400_tuning_ctrl hs400_tuning_ctrl_i0 (
		.clk                 (sd_clk),
		.rst                 (rst),
		.idly_tuning_start   (idly_tuning_start),
		.idly_tuning_ready   (idly_tuning_ready),
		.idly_tuning_done    (idly_tuning_done),
		.idly_tuning_failed  (idly_tuning_failed),
		.idly_tuning_timeout (timeout_delay),
		.data_strobe         (ds_in_iddr),
		.cntval_in           (cntval_in),
		.cntval_load         (cntval_load),
		.cntval_out          (cntval_out)
	);


	//---------------------- buffer inst ----------------------
	sd_emmc_obuf #(.DATA_WIDTH(1)) sd_emmc_obuf_i0 (.do_i(sd_clk_90_s), .do_pad(sd_clk_pad));
	sd_emmc_iobuf #(.DATA_WIDTH(1)) sd_emmc_iobuf_i0 (.dio_t(cmd_t_s), .dio_i(cmd_out_s), .dio_o(cmd_in_s), .dio_pad(sd_cmd_pad));
	sd_emmc_iobuf #(.DATA_WIDTH(8)) sd_emmc_iobuf_i1 (.dio_t(data_t_s), .dio_i(data_out_s), .dio_o(data_in_s), .dio_pad(sd_data_pad));
	sd_emmc_ibuf #(.DATA_WIDTH(1)) sd_emmc_ibuf_i0 (.di_o(ds_in_s), .di_pad(sd_ds_pad));


endmodule
