// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : sd_emmc_user.v
// Create : 2019-12-18 17:07:11
// Revised: 2019-12-19 10:09:12
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module sd_emmc_user(
		input sd_clk,
		input rst,
		input int_status_rst,
		// input cmd
		input [1:0] setting_i,
		input [39:0] cmd_i,
		input start_xfr_i,
		input busy_check_i,
		// output cmd
		output [1:0] setting_o,
		output [39:0] cmd_o,
		output start_xfr_o,
		// input response
		input [119:0] response_i,
		input crc_ok_i,
		input index_ok_i,
		input finish_i,
		input busy_i, //direct signal from data sd data input (data[0])
		// output response
		output [`INT_CMD_SIZE-1:0] int_status_o,
		output [31:0] response_0_o,
		output [31:0] response_1_o,
		output [31:0] response_2_o,
		output [31:0] response_3_o
    );

	reg start_xfr_q;
	reg start_xfr_qq;
	wire start_xfr;

	reg go_idle;
	reg [`CMD_TIMEOUT_W-1:0] timeout_reg;
	reg crc_check;
	reg index_check;
	reg busy_check;
	reg expect_response;
	reg long_response;
	reg [`INT_CMD_SIZE-1:0] int_status_reg;

	reg [39:0] cmd_r;

	reg [31:0] response_0_r;
	reg [31:0] response_1_r;
	reg [31:0] response_2_r;
	reg [31:0] response_3_r;
	reg start_xfr_o_r;

	reg [`CMD_TIMEOUT_W-1:0] watchdog;
	localparam SIZE = 2;
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state;
	localparam IDLE       = 2'b00;
	localparam EXECUTE    = 2'b01;
	localparam BUSY_CHECK = 2'b10;

	assign setting_o[1:0] = {long_response, expect_response};
	assign int_status_o = state == IDLE ? int_status_reg : 5'h0;

	// input buffer
	always @ (posedge sd_clk)
		if (rst) begin
			start_xfr_q <= 0;
			start_xfr_qq <= 0;
		end
		else begin
			start_xfr_q <= start_xfr_i;
			start_xfr_qq <= start_xfr_q;
		end

	assign start_xfr = ({start_xfr_qq, start_xfr_q}==2'b01);

	always @(state or start_xfr or finish_i or go_idle or busy_check or busy_i)
		begin : FSM_COMBO
			case(state)
				IDLE : begin
					if (start_xfr)
						next_state <= EXECUTE;
					else
						next_state <= IDLE;
				end
				EXECUTE : begin
					if ((finish_i && !busy_check) || go_idle)
						next_state <= IDLE;
					else if (finish_i && busy_check)
						next_state <= BUSY_CHECK;
					else
						next_state <= EXECUTE;
				end
				BUSY_CHECK : begin
					if (!busy_i)
						next_state <= IDLE;
					else
						next_state <= BUSY_CHECK;
				end
				default : next_state <= IDLE;
			endcase
		end

	always @(posedge sd_clk or posedge rst)
		begin : FSM_SEQ
			if (rst) begin
				state <= IDLE;
			end
			else begin
				state <= next_state;
			end
		end

	always @(posedge sd_clk or posedge rst)
		begin
			if (rst) begin
				crc_check       <= 0;
				response_0_r    <= 0;
				response_1_r    <= 0;
				response_2_r    <= 0;
				response_3_r    <= 0;
				int_status_reg  <= 0;
				expect_response <= 0;
				long_response   <= 0;
				cmd_r           <= 0;
				start_xfr_o_r     <= 0;
				index_check     <= 0;
				busy_check      <= 0;
				watchdog        <= 0;
				timeout_reg     <= 0;
				go_idle       <= 0;
			end
			else begin
				case(state)
					IDLE : begin
						go_idle   <= 0;
						index_check <= 1;
						crc_check   <= 1;
						busy_check  <= busy_check_i;
						expect_response <= setting_i[0];
						long_response   <= setting_i[1];
						cmd_r[39:38] <= 2'b01;
						cmd_r[37:32] <= cmd_i[37:32];  //CMD_INDEX
						cmd_r[31:0]  <= cmd_i[31:0]; //CMD_Argument
						timeout_reg  <= 250;
						watchdog     <= 0;
						if (start_xfr) begin
							start_xfr_o_r <= 1;
							int_status_reg <= 0;
						end
					end
					EXECUTE : begin
						start_xfr_o_r <= 0;
						watchdog    <= watchdog + `CMD_TIMEOUT_W'd1;
						if (timeout_reg && watchdog >= timeout_reg) begin
							int_status_reg[`INT_CMD_CTE] <= 1;
							int_status_reg[`INT_CMD_EI]  <= 1;
							go_idle                    <= 1;
						end
						//Incoming New Status
						else begin //if ( req_in_int == 1) begin
							if (finish_i) begin //Data avaible
								if (crc_check & !crc_ok_i) begin
									int_status_reg[`INT_CMD_CCRCE] <= 1;
									int_status_reg[`INT_CMD_EI]    <= 1;
								end
								if (index_check & !index_ok_i) begin
									int_status_reg[`INT_CMD_CIE] <= 1;
									int_status_reg[`INT_CMD_EI]  <= 1;
								end
								if (next_state != BUSY_CHECK) begin
									int_status_reg[`INT_CMD_CC] <= 1;
								end
								if (expect_response != 0 & (~long_response)) begin
									response_0_r <= response_i[119:88];
								end
								else if (expect_response != 0 & long_response) begin
									response_3_r <= {8'h00, response_i[119:96]};
									response_2_r <= response_i[95:64];
									response_1_r <= response_i[63:32];
									response_0_r <= response_i[31:0];
								end
								// end
							end ////Data avaible
						end //Status change
					end //EXECUTE state
					BUSY_CHECK : begin
						start_xfr_o_r <= 0;
						go_idle   <= 0;
						if (next_state != BUSY_CHECK) begin
							int_status_reg[`INT_CMD_CC] <= 1;
							int_status_reg[`INT_CMD_DC] <= 1;
						end
					end
				endcase
				if (int_status_rst)
					int_status_reg <= 0;
			end
		end

	// output logic
	assign response_0_o = response_0_r;
	assign response_1_o = response_1_r;
	assign response_2_o = response_2_r;
	assign response_3_o = response_3_r;

	assign start_xfr_o = start_xfr_o_r;
	assign cmd_o = cmd_r;

endmodule
