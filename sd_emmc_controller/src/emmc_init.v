// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : emmc_init.v
// Create : 2019-11-22 11:50:12
// Revised: 2019-12-20 09:52:23
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "sd_emmc_header.vh"

module emmc_init(
		input sd_clk,
		input sd_rst_n,
		//
		output [1:0] setting_o,
		output [39:0] cmd_o,
		output start_xfr_o,
		input [119:0] response_i,
		input crc_ok_i,
		input index_ok_i,
		input finish_i,
		input busy_i, //direct signal from data sd data input (data[0])
		// misc
		input start_init,
		output init_failed,
		output init_done
    );

	//________________________________________________________
	// clogb2 function

	function integer clogb2 (input integer bit_depth);
		begin
			for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
				bit_depth = bit_depth >> 1;
		end
	endfunction 


	localparam CMD_TIMEOUT_CYCLE = 1024;
	localparam SEQ_CNT_WIDTH = clogb2(`NUM_INIT-1);

	localparam IDLE = 2'd0;
	localparam EXECUTE = 2'd1;
	localparam DONE = 2'd2;
	localparam FAILED = 2'd3;

	wire [`INSTRU_WIDTH-1:0] init_seq;

	reg finish_q;
	reg finish_qq;

	reg [1:0] setting_r;
	reg [39:0] cmd_r;
	reg start_xfr_r;
	reg checkcrc;
	wire crc_err;

	reg [9:0] watchdog;
	wire watchdog_timeout;

	reg next_seq;
	reg [SEQ_CNT_WIDTH-1:0] sequence_cnt;
	reg sequence_done;
	reg sequence_failed;
	wire sequece_finish;

	reg [1:0] mst_state;

	init_seq_rom init_seq_i0 (.addr(sequence_cnt), .dout(init_seq));

	// input buffer
	always @ (posedge sd_clk)
		if(!sd_rst_n) begin
			finish_q <= 0;
			finish_qq <= 0;
		end
		else begin
			finish_q <= finish_i;
			finish_qq <= finish_q;
		end

	// sequence machine
	always @ (posedge sd_clk)
		if(!sd_rst_n)
			sequence_cnt <= 0;
		else if(next_seq)
			sequence_cnt <= sequence_cnt + 1;
		else
			sequence_cnt <= sequence_cnt;

	always @ (posedge sd_clk)
		if(!sd_rst_n)
			next_seq <= 0;
		else
			case(sequence_cnt)
				1 : begin
					if(response_i[119]&&finish_i)
						next_seq <= 1;
					else
						next_seq <= 0;
				end
				default : next_seq <= (finish_i==1'b1)&&(mst_state==EXECUTE);
			endcase

	always @ (posedge sd_clk)
		if(!sd_rst_n) begin
			setting_r <= 0;
			cmd_r <= 0;
			checkcrc <= 0;
			start_xfr_r <= 0;
		end
		else begin
			setting_r <= init_seq[`SETTING_INDEX];
			checkcrc <= init_seq[`CHECKCRC_INDEX];
			cmd_r <= init_seq[`CMD_CONTENT_INDEX];
			start_xfr_r <= ((start_init==1'b1)&&(mst_state==IDLE))||((finish_qq==1'b1)&&(mst_state==EXECUTE));
		end

	// watch dog
	always @ (posedge sd_clk)
		if(!sd_rst_n||finish_i)
			watchdog <= 0;
		else if(watchdog==CMD_TIMEOUT_CYCLE-1)
			watchdog <= watchdog;
		else if(mst_state==EXECUTE)
			watchdog <= watchdog + 1;
		else
			watchdog <= watchdog;

	// sequece machine status monitor

	assign watchdog_timeout = (watchdog==CMD_TIMEOUT_CYCLE-1);
	assign crc_err = ({checkcrc, crc_ok_i, finish_i}==3'b101);
	assign sequece_finish = (sequence_cnt==`NUM_INIT-1)&&(finish_i==1'b1);

	always @ (posedge sd_clk)
		if(!sd_rst_n) begin
			sequence_done <= 0;
			sequence_failed <= 0;
		end
		else begin
			if(watchdog_timeout||crc_err)
				sequence_failed <= 1;
			else
				sequence_failed <= 0;
			if(sequece_finish)
				sequence_done <= 1;
			else
				sequence_done <= 0;
		end


	// main state machine
	always @ (posedge sd_clk)
		if(!sd_rst_n)
			mst_state <= IDLE;
		else
			case (mst_state)
				IDLE :
					if(start_init)
						mst_state <= EXECUTE;
					else
						mst_state <= IDLE;
				EXECUTE :
					if(sequence_done)
						mst_state <= DONE;
					else if(sequence_failed)
						mst_state <= FAILED;
					else
						mst_state <= EXECUTE;

				DONE :
					mst_state <= DONE;

				FAILED :
					mst_state <= FAILED;
			endcase

	// output logic
	assign setting_o = setting_r;
	assign cmd_o = cmd_r;
	assign start_xfr_o = start_xfr_r;

	assign init_done = (mst_state==DONE)||(mst_state==FAILED);
	assign init_failed = (mst_state==FAILED);

endmodule

module init_seq_rom (
	input [1:0] addr,
	output [`INSTRU_WIDTH-1:0] dout
);
	wire [`INSTRU_WIDTH-1:0] init_seq_instruction[`INSTRU_WIDTH-1:0];
	// longresp/withresp, waitbusy, checkcrc, startbit, cmdindex, argument
	assign init_seq_instruction[0] = {2'b00, 1'b0, 1'b0, 2'b01, 6'd0, 32'h0000_0000};
	assign init_seq_instruction[1] = {2'b01, 1'b0, 1'b0, 2'b01, 6'd1, 32'h4000_0080};
	assign init_seq_instruction[2] = {2'b11, 1'b0, 1'b1, 2'b01, 6'd2, 32'h0000_0000};
	assign init_seq_instruction[3] = {2'b01, 1'b0, 1'b1, 2'b01, 6'd3, `RCA_ADDR, 16'h0000};

	assign dout = init_seq_instruction[addr];

endmodule
