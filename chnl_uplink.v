// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : system_top.v
// Create : 2019-05-10 17:30:21
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module chnl_uplink #(parameter C_PCI_DATA_WIDTH = 64) (
		input                         CLK               ,
		input                         RST               ,
		output                        CHNL_RX_CLK       ,
		input                         CHNL_RX           ,
		output                        CHNL_RX_ACK       ,
		input                         CHNL_RX_LAST      ,
		input  [                31:0] CHNL_RX_LEN       ,
		input  [                30:0] CHNL_RX_OFF       ,
		input  [C_PCI_DATA_WIDTH-1:0] CHNL_RX_DATA      ,
		input                         CHNL_RX_DATA_VALID,
		output                        CHNL_RX_DATA_REN  ,
		output                        CHNL_TX_CLK       ,
		output                        CHNL_TX           ,
		input                         CHNL_TX_ACK       ,
		output                        CHNL_TX_LAST      ,
		output [                31:0] CHNL_TX_LEN       ,
		output [                30:0] CHNL_TX_OFF       ,
		output [C_PCI_DATA_WIDTH-1:0] CHNL_TX_DATA      ,
		output                        CHNL_TX_DATA_VALID,
		input                         CHNL_TX_DATA_REN  ,
		input  [                31:0] uplink_len        ,
		output                        fifo_rden         ,
		input  [C_PCI_DATA_WIDTH-1:0] fifo_rddata       ,
		input                         fifo_empty
	);

	reg [31:0] rLen=0;
	reg [31:0] rCount=0;
	reg [1:0] rState=0;

	reg [31:0] tCount=0;
	reg [C_PCI_DATA_WIDTH-1:0] tData={C_PCI_DATA_WIDTH{1'b0}};
	reg tValid=0;
	reg [1:0] tState=0;
	reg [31:0] uplink_len_r=0;

	assign CHNL_RX_CLK = CLK;
	assign CHNL_RX_ACK = (rState==2'd1);
	assign CHNL_RX_DATA_REN = (rState==2'd1);

	assign CHNL_TX_CLK = CLK;
	assign CHNL_TX = (tState == 2'd1);
	assign CHNL_TX_LAST = 1'd1;
	assign CHNL_TX_LEN = uplink_len_r; // in words
	assign CHNL_TX_OFF = 0;
	assign CHNL_TX_DATA = tData;
	assign CHNL_TX_DATA_VALID = tValid;

	assign fifo_rden = (tState==2'd1)&&(!fifo_empty)&&(CHNL_TX_DATA_REN);

	always @ (posedge CLK) begin
		uplink_len_r <= uplink_len;
	end

	always @ (posedge CLK)
		if (RST) begin
			rLen <= 0;
			rCount <= 0;
			rState <= 0;
		end
		else 
			case (rState)
				2'd0: begin // Wait for start of RX, save length
					if (CHNL_RX) begin
						rLen <= CHNL_RX_LEN;
						rCount <= 0;
						rState <= 2'd1;
					end
					else begin
						rLen <= 0;
						rCount <= 0;
						rState <= 0;
					end
				end
				2'd1: begin // Wait for last data in RX
					if (CHNL_RX_DATA_VALID)
						rCount <= rCount + (C_PCI_DATA_WIDTH/32);
					if (rCount >= rLen)
						rState <= 2'd0;
					else
						rState <= 2'd1;
				end
				default : begin
					rLen <= 0;
					rCount <= 0;
					rState <= 0;
				end				
			endcase

	always @ (posedge CLK)
		if (RST) begin
			tCount <= 0;
			tData <= 0;
			tValid <= 0;
			tState <= 0;
		end
		else
			case(tState)
				2'd0 : begin
					if(fifo_empty==0) begin
						tCount <= (C_PCI_DATA_WIDTH/32);
						tState <= 2'd1;
					end
					else begin
						tCount <= 0;
						tState <= 2'd0;
					end
				end
				2'd1 : begin
					tData <= fifo_rddata;
					tValid <= fifo_rden;
					if(fifo_rden==1) begin
						tCount <= tCount + (C_PCI_DATA_WIDTH/32);
						if (tCount >= uplink_len_r)
							tState <= 2'd0;
						else
							tState <= 2'd1;
					end
					else begin
						tCount <= tCount;
						tState <= 2'd1;
					end
				end
				default : begin
					tCount <= 0;
					tData <= 0;
					tValid <= 0;
					tState <= 0;
				end
			endcase



endmodule
