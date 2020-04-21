// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : ads8556_if.v
// Create : 2019-07-04 09:46:18
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module ads8556_if #(parameter CLK_FREQ = 100_000_000)(
		// clock & reset
		input         clk             ,
		input         rst_n           ,
		// ads8556 data interface
		output        ads8556_wrn     ,
		output        ads8556_rdn     ,
		output        ads8556_csn     ,
		input         ads8556_busy    ,
		input  [15:0] ads8556_data_in ,
		output [15:0] ads8556_data_out,
		output        ads8556_data_t  ,
		// ads8556 control interface
		input         ads8556_syncn   ,
		output        ads8556_conv    ,
		output        ads8556_standbyn,
		output        ads8556_reset   ,
	    // data interface
		output [15:0] data_ch0        ,
		output [15:0] data_ch1        ,
		output [15:0] data_ch2        ,
		output [15:0] data_ch3        ,
		output [15:0] data_ch4        ,
		output [15:0] data_ch5        ,
		output        data_valid      ,
	    // misc ports (option)
		output        data_clk2m
	);

	function integer clogb2;
		input [31:0] value;
		reg   [31:0] my_value;
		begin
			my_value = value - 1;
			for (clogb2 = 0; my_value > 0; clogb2 = clogb2 + 1)
				my_value = my_value >> 1;
		end
	endfunction

	localparam SMPL_DIV4_NUM = 4;
	localparam SMPL_CHNL_NUM = 6;
	localparam FREQ10M_RATE = 10_000_000;  //rdclk
	localparam RDDATA_CNT = CLK_FREQ / FREQ10M_RATE / 2;
	localparam FREQ2M_RATE = 2_000_000;
	localparam FREQ2M_CNT = CLK_FREQ / FREQ2M_RATE / 2;

	localparam INIT         = 2'd0;
	localparam IDLE         = 2'd1;
	localparam READ         = 2'd2;
	localparam WAIT_NXTCONV = 2'd3;

	localparam RDDATA_CNT_WID = clogb2(RDDATA_CNT);
	localparam FREQ2M_CNT_WID = clogb2(FREQ2M_CNT);

	localparam CTRL_REG_H = 16'hfC00;
	localparam CTRL_REG_L = 16'h03ff;

	reg [RDDATA_CNT_WID-1:0] rdclk_cnt = 0;
	reg [FREQ2M_CNT_WID-1:0] clk2m_cnt = 0;

	reg rdclk = 0;
	reg clk2m = 0;

	reg rdclk_r = 0;			  //main state machine drive clock
	wire rdclk_edge;

	wire init_finished;

	reg [2:0] smpl_pulse_cnt = 0; //clk2m divide by 4
	reg smpl_pulse = 0;
	reg smpl_pulse_r = 0;
	wire smpl_pulse_rise_edge;

	wire read_finished;

	reg conv_r = 0;

	reg [3:0] data_step = 0; // data io lsm count
	reg [15:0] data_out_r = 0;
	reg data_t_r = 0; // 0---output 1---input
	reg [95:0] data_in_cache = 0;

	reg wrn_r = 1;
	reg rdn_r = 1;
	reg csn_r = 1;

	reg [95:0] data_ch_r = 0;
	reg data_valid_r = 0;

	reg [1:0] mst_state = INIT;

	// clock generator
	always @ (posedge clk) // drive main state machine 10mhz
		if(!rst_n) begin
			rdclk_cnt <= 0;
			rdclk <= 0;
		end
		else begin
			if(rdclk_cnt==RDDATA_CNT-1)
				rdclk_cnt <= 0;
			else
				rdclk_cnt <= rdclk_cnt + 1'b1;
			if(rdclk_cnt==RDDATA_CNT-1)
				rdclk <= ~rdclk;
			else
				rdclk <= rdclk;
		end

	always @ (posedge clk) // drive 2mhz output
		if(!rst_n) begin
			clk2m_cnt <= 0;
			clk2m <= 0;
		end
		else begin
			if(clk2m_cnt==FREQ2M_CNT-1)
				clk2m_cnt <= 0;
			else
				clk2m_cnt <= clk2m_cnt + 1'b1;
			if(clk2m_cnt==FREQ2M_CNT-1)
				clk2m <= ~clk2m;
			else
				clk2m <= clk2m;
		end

	always @ (posedge clk) 
		if(!rst_n) 
			rdclk_r <= 0;
		else 
			rdclk_r <= rdclk;

	assign rdclk_edge = ({rdclk_r, rdclk}==2'b01)||({rdclk_r, rdclk}==2'b10);

	always @ (posedge clk) // drive sample trigger
		if(!rst_n||ads8556_syncn) begin
			smpl_pulse_cnt <= 0;
			smpl_pulse <= 0;
		end
		else begin
			if(clk2m_cnt==FREQ2M_CNT-1)
				smpl_pulse_cnt <= smpl_pulse_cnt + 1'b1;
			else
				smpl_pulse_cnt <= smpl_pulse_cnt;
			smpl_pulse <= smpl_pulse_cnt[2];
		end

	always @ (posedge clk)
		if(!rst_n) 
			smpl_pulse_r <= 0;
		else if(rdclk_edge)
			smpl_pulse_r <= smpl_pulse;
		else
			smpl_pulse_r <= smpl_pulse_r;

	assign smpl_pulse_rise_edge = ({smpl_pulse_r, smpl_pulse}==2'b01);

	// lsm counter
	always @ (posedge clk)
		if(!rst_n) 
			data_step <= 0;
		else
			case(mst_state)
				INIT : begin
					if({ads8556_busy, rdclk_edge}==2'b01)
						if(data_step==5)
							data_step <= data_step;
						else
							data_step <= data_step + 1'b1;
				end
				READ : begin
					if({ads8556_busy, rdclk_edge}==2'b01)
						if(data_step==13)
							data_step <= data_step;
						else
							data_step <= data_step + 1'b1;
				end
				default : data_step <= 0;
			endcase

	assign init_finished = (data_step==5) && (mst_state==INIT);
	assign read_finished = (data_step==12) && (mst_state==READ);

	// convert signal generator
	always @ (posedge clk)
		if(!rst_n)
			conv_r <= 0;
		else
			case(mst_state)
				IDLE : begin
					if({rdclk_edge, smpl_pulse_rise_edge}==2'b11)
						conv_r <= 1;
					else
						conv_r <= conv_r;
				end
				READ : begin
					if({ads8556_busy, rdclk_edge}==2'b01)
						conv_r <= 0;
					else
						conv_r <= conv_r;
				end
				default : begin
					conv_r <= 0;
				end
			endcase 

	// io drive
	always @ (posedge clk)
		if(!rst_n) begin
			data_out_r <= 0;
			data_t_r <= 1;
			data_in_cache <= 0;
		end
		else 
			case(mst_state)
				INIT : begin
					case (data_step)
						0 : begin
							data_t_r <= 0;
							data_out_r <= 0;
						end
						1, 2 : begin
							data_t_r <= 0;
							data_out_r <= CTRL_REG_H;
						end
						3, 4 : begin
							data_t_r <= 0;
							data_out_r <= CTRL_REG_L;
						end
						default : begin 
							data_t_r <= 0;
							data_out_r <= data_out_r;
						end
					endcase
				end
				IDLE : begin
					data_t_r <= 1;
					data_out_r <= 0;
				end
				READ : begin
					case (data_step)
						0 : begin
							data_t_r <= 1;
							data_in_cache <= 0;
						end
						1, 3, 5, 7, 9, 11 : begin
							data_t_r <= 1;
							if(rdclk_edge)
								data_in_cache <= {data_in_cache[79:0], ads8556_data_in};
							else
								data_in_cache <= data_in_cache;
						end
						default : begin
							data_t_r <= 1;
							data_in_cache <= data_in_cache;
						end
					endcase
				end
				default : begin
					data_t_r <= data_t_r;
					data_in_cache <= data_in_cache;
					data_out_r <= data_out_r;
				end
			endcase

	// read/write control
	always @ (posedge clk)
		if(!rst_n) begin
			wrn_r <= 1;
			rdn_r <= 1;
			csn_r <= 1;
		end
		else 
			case (mst_state)
				INIT : begin
					case (data_step)
						1, 3 : begin
							wrn_r <= 0;
							csn_r <= 0;
						end
						2, 4 : begin
							wrn_r <= 1;
							csn_r <= 0;
						end
						default : begin
							wrn_r <= 1;
							rdn_r <= 1;
							csn_r <= 1;
						end						
					endcase
				end
				READ : begin
					case (data_step)
						1, 3, 5, 7, 9, 11 : begin
							rdn_r <= 0;
							csn_r <= 0;
						end
						2, 4, 6, 8, 10, 12 : begin
							rdn_r <= 1;
							csn_r <= 0;
						end
						default : begin
							wrn_r <= 1;
							rdn_r <= 1;
							csn_r <= 1;
						end
					endcase
				end
				default : begin
					wrn_r <= 1;
					rdn_r <= 1;
					csn_r <= 1;
				end
			endcase

	// data output register
	always @ (posedge clk)
		if(!rst_n) begin
			data_ch_r <= 0;
			data_valid_r <= 0;
		end
		else if((mst_state==READ)&&read_finished&&rdclk_edge) begin
			data_ch_r <= data_in_cache;
			data_valid_r <= 1;
		end
		else begin
			data_ch_r <= data_ch_r;
			data_valid_r <= 0;
		end


	// main state machine
	always @ (posedge clk)
		if(!rst_n)
			mst_state <= INIT;
		else if(rdclk_edge)
			case(mst_state)
				INIT : 
					if(init_finished)
						mst_state <= IDLE;
					else
						mst_state <= INIT;

				IDLE : 
					if(smpl_pulse_rise_edge)
						mst_state <= READ;
					else
						mst_state <= IDLE;

				READ : 
					if(read_finished)
						mst_state <= WAIT_NXTCONV;
					else
						mst_state <= READ;

				WAIT_NXTCONV : 
					mst_state <= IDLE;

			endcase // mst_state

	// output assignment
	assign ads8556_data_t = data_t_r;
	assign ads8556_data_out = data_out_r;
	assign ads8556_csn = csn_r;
	assign ads8556_rdn = rdn_r;
	assign ads8556_wrn = wrn_r;

	assign ads8556_conv = conv_r;
	assign ads8556_standbyn = 1'b1;
	assign ads8556_reset = 1'b0;

	assign data_ch5 = data_ch_r[15:0];
	assign data_ch4 = data_ch_r[31:16];
	assign data_ch3 = data_ch_r[47:32];
	assign data_ch2 = data_ch_r[63:48];
	assign data_ch1 = data_ch_r[79:64];
	assign data_ch0 = data_ch_r[95:80];
	assign data_valid = data_valid_r;

	assign data_clk2m = clk2m;

endmodule
