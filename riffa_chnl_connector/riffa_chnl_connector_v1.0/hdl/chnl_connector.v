// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : chnl_connect.v
// Create : 2019-05-10 15:19:07
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module chnl_connector #(
		parameter CHNL_NUM         = 2 ,
		parameter C_PCI_DATA_WIDTH = 32
	)(
		// RIFFA CHANNEL RX
		output [                 CHNL_NUM-1:0] CHNL_RX_CLK            ,
		input  [                 CHNL_NUM-1:0] CHNL_RX                ,
		output [                 CHNL_NUM-1:0] CHNL_RX_ACK            ,
		input  [                 CHNL_NUM-1:0] CHNL_RX_LAST           ,
		input  [              CHNL_NUM*32-1:0] CHNL_RX_LEN            ,
		input  [              CHNL_NUM*31-1:0] CHNL_RX_OFF            ,
		input  [CHNL_NUM*C_PCI_DATA_WIDTH-1:0] CHNL_RX_DATA           ,
		input  [                 CHNL_NUM-1:0] CHNL_RX_DATA_VALID     ,
		output [                 CHNL_NUM-1:0] CHNL_RX_DATA_REN       ,
		// RIFFA CHANNEL TX
		output [                 CHNL_NUM-1:0] CHNL_TX_CLK            ,
		output [                 CHNL_NUM-1:0] CHNL_TX                ,
		input  [                 CHNL_NUM-1:0] CHNL_TX_ACK            ,
		output [                 CHNL_NUM-1:0] CHNL_TX_LAST           ,
		output [              CHNL_NUM*32-1:0] CHNL_TX_LEN            ,
		output [              CHNL_NUM*31-1:0] CHNL_TX_OFF            ,
		output [CHNL_NUM*C_PCI_DATA_WIDTH-1:0] CHNL_TX_DATA           ,
		output [                 CHNL_NUM-1:0] CHNL_TX_DATA_VALID     ,
		input  [                 CHNL_NUM-1:0] CHNL_TX_DATA_REN       ,
		// RIFFA CHANNEL CMD RX
		input                                  CHNL_CMD_RX_CLK        ,
		output                                 CHNL_CMD_RX            ,
		input                                  CHNL_CMD_RX_ACK        ,
		output                                 CHNL_CMD_RX_LAST       ,
		output [                         31:0] CHNL_CMD_RX_LEN        ,
		output [                         30:0] CHNL_CMD_RX_OFF        ,
		output [         C_PCI_DATA_WIDTH-1:0] CHNL_CMD_RX_DATA       ,
		output                                 CHNL_CMD_RX_DATA_VALID ,
		input                                  CHNL_CMD_RX_DATA_REN   ,
		// RIFFA CHANNEL CMD TX
		input                                  CHNL_CMD_TX_CLK        ,
		input                                  CHNL_CMD_TX            ,
		output                                 CHNL_CMD_TX_ACK        ,
		input                                  CHNL_CMD_TX_LAST       ,
		input  [                         31:0] CHNL_CMD_TX_LEN        ,
		input  [                         30:0] CHNL_CMD_TX_OFF        ,
		input  [         C_PCI_DATA_WIDTH-1:0] CHNL_CMD_TX_DATA       ,
		input                                  CHNL_CMD_TX_DATA_VALID ,
		output                                 CHNL_CMD_TX_DATA_REN   ,
		// RIFFA CHANNEL DATA RX
		input                                  CHNL_DATA_RX_CLK       ,
		output                                 CHNL_DATA_RX           ,
		input                                  CHNL_DATA_RX_ACK       ,
		output                                 CHNL_DATA_RX_LAST      ,
		output [                         31:0] CHNL_DATA_RX_LEN       ,
		output [                         30:0] CHNL_DATA_RX_OFF       ,
		output [         C_PCI_DATA_WIDTH-1:0] CHNL_DATA_RX_DATA      ,
		output                                 CHNL_DATA_RX_DATA_VALID,
		input                                  CHNL_DATA_RX_DATA_REN  ,
		// RIFFA CHANNEL DATA TX
		input                                  CHNL_DATA_TX_CLK       ,
		input                                  CHNL_DATA_TX           ,
		output                                 CHNL_DATA_TX_ACK       ,
		input                                  CHNL_DATA_TX_LAST      ,
		input  [                         31:0] CHNL_DATA_TX_LEN       ,
		input  [                         30:0] CHNL_DATA_TX_OFF       ,
		input  [         C_PCI_DATA_WIDTH-1:0] CHNL_DATA_TX_DATA      ,
		input                                  CHNL_DATA_TX_DATA_VALID,
		output                                 CHNL_DATA_TX_DATA_REN
	);

	// riffa channel
	assign CHNL_RX_CLK      = {CHNL_DATA_RX_CLK, CHNL_CMD_RX_CLK};
	assign CHNL_RX_ACK      = {CHNL_DATA_RX_ACK, CHNL_CMD_RX_ACK};
	assign CHNL_RX_DATA_REN = {CHNL_DATA_RX_DATA_REN, CHNL_CMD_RX_DATA_REN};

	assign CHNL_TX_CLK        = {CHNL_DATA_TX_CLK, CHNL_CMD_TX_CLK};
	assign CHNL_TX            = {CHNL_DATA_TX, CHNL_CMD_TX};
	assign CHNL_TX_LAST       = {CHNL_DATA_TX_LAST, CHNL_CMD_TX_LAST};
	assign CHNL_TX_LEN        = {CHNL_DATA_TX_LEN, CHNL_CMD_TX_LEN};
	assign CHNL_TX_OFF        = {CHNL_DATA_TX_OFF, CHNL_CMD_TX_OFF};
	assign CHNL_TX_DATA       = {CHNL_DATA_TX_DATA, CHNL_CMD_TX_DATA};
	assign CHNL_TX_DATA_VALID = {CHNL_DATA_TX_DATA_VALID, CHNL_CMD_TX_DATA_VALID};
	
	// cmd
	assign CHNL_CMD_RX = CHNL_RX[0];
	assign CHNL_CMD_RX_LAST = CHNL_RX_LAST[0];
	assign CHNL_CMD_RX_LEN = CHNL_RX_LEN[31:0];
	assign CHNL_CMD_RX_OFF = CHNL_RX_OFF[30:0];
	assign CHNL_CMD_RX_DATA = CHNL_RX_DATA[C_PCI_DATA_WIDTH*0+C_PCI_DATA_WIDTH-1:C_PCI_DATA_WIDTH*0];
	assign CHNL_CMD_RX_DATA_VALID = CHNL_RX_DATA_VALID[0];

	assign CHNL_CMD_TX_ACK = CHNL_TX_ACK[0];
	assign CHNL_CMD_TX_DATA_REN = CHNL_TX_DATA_REN[0];

	// data
	assign CHNL_DATA_RX = CHNL_RX[1];
	assign CHNL_DATA_RX_LAST = CHNL_RX_LAST[1];
	assign CHNL_DATA_RX_LEN = CHNL_RX_LEN[63:32];
	assign CHNL_DATA_RX_OFF = CHNL_RX_OFF[61:31];
	assign CHNL_DATA_RX_DATA = CHNL_RX_DATA[C_PCI_DATA_WIDTH*1+C_PCI_DATA_WIDTH-1:C_PCI_DATA_WIDTH*1];
	assign CHNL_DATA_RX_DATA_VALID = CHNL_RX_DATA_VALID[1];

	assign CHNL_DATA_TX_ACK = CHNL_TX_ACK[1];
	assign CHNL_DATA_TX_DATA_REN = CHNL_TX_DATA_REN[1];


endmodule
