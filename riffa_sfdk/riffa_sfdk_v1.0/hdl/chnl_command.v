// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : chnl_command.v
// Create : 2019-04-29 14:59:23
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

// `define C_PCI_DATA_WIDTH_32
`define C_PCI_DATA_WIDTH_64
// `define C_PCI_DATA_WIDTH_128

// Command frame format
//--------------------------------------------------------------------------------------
// Packet type 					|Head 			|Addr 		 |Data 			|Tail
//--------------------------------------------------------------------------------------
// Write Register (PC-->FPGA)	|0x87873D3D 	|addr[31:0]  |data[31:0] 	|xxxxxxxx
// Read Register (PC-->FPGA)	|0x98984E4E 	|addr[31:0]  |data[31:0] 	|xxxxxxxx
// Write Response (FPGA-->PC)	|0x7F7F5E5E 	|addr[31:0]  |data[31:0] 	|0x8B8B6D6D
// Read Response (FPGA-->PC)	|0x7F7F5E5E 	|addr[31:0]  |data[31:0] 	|0x8B8B6D6D
// Read Error (FPGA-->PC)		|0x7F7F5E5E 	|addr[31:0]  |data[31:0] 	|0xE0E0E0E0
// Write Error (FPGA-->PC)		|0x7F7F5E5E 	|addr[31:0]  |data[31:0] 	|0xE0E0E0E0
// Head Error (FPGA-->PC)		|0x7F7F5E5E 	|addr[31:0]  |data[31:0] 	|0xE1E1E1E1

module chnl_command #(parameter C_PCI_DATA_WIDTH = 32) (
	input                         CHNL_CLK          ,
	input                         RST_N             ,
	// RIFFA CHANNEL RX
	output                        CHNL_RX_CLK       ,
	input                         CHNL_RX           ,
	output                        CHNL_RX_ACK       ,
	input                         CHNL_RX_LAST      ,
	input  [                31:0] CHNL_RX_LEN       ,
	input  [                30:0] CHNL_RX_OFF       ,
	input  [C_PCI_DATA_WIDTH-1:0] CHNL_RX_DATA      ,
	input                         CHNL_RX_DATA_VALID,
	output                        CHNL_RX_DATA_REN  ,
	// RIFFA CHANNEL TX
	output                        CHNL_TX_CLK       ,
	output                        CHNL_TX           ,
	input                         CHNL_TX_ACK       ,
	output                        CHNL_TX_LAST      ,
	output [                31:0] CHNL_TX_LEN       ,
	output [                30:0] CHNL_TX_OFF       ,
	output [C_PCI_DATA_WIDTH-1:0] CHNL_TX_DATA      ,
	output                        CHNL_TX_DATA_VALID,
	input                         CHNL_TX_DATA_REN  ,
	// AXI4_LITE
	output                        cmd_m_axi_awvalid ,
	output [                31:0] cmd_m_axi_awaddr  ,
	input                         cmd_m_axi_awready ,
	output                        cmd_m_axi_wvalid  ,
	output [                31:0] cmd_m_axi_wdata   ,
	output [                 3:0] cmd_m_axi_wstrb   ,
	input                         cmd_m_axi_wready  ,
	input                         cmd_m_axi_bvalid  ,
	input  [                 1:0] cmd_m_axi_bresp   ,
	output                        cmd_m_axi_bready  ,
	output                        cmd_m_axi_arvalid ,
	output [                31:0] cmd_m_axi_araddr  ,
	input                         cmd_m_axi_arready ,
	input                         cmd_m_axi_rvalid  ,
	input  [                 1:0] cmd_m_axi_rresp   ,
	input  [                31:0] cmd_m_axi_rdata   ,
	output                        cmd_m_axi_rready
);

	reg [C_PCI_DATA_WIDTH-1:0] rData = {C_PCI_DATA_WIDTH{1'b0}};
	reg [C_PCI_DATA_WIDTH-1:0] tData = {C_PCI_DATA_WIDTH{1'b0}};
	reg [31:0] rLen = 0;
	reg [31:0] rCount = 0;
	reg [2:0] tCount = 0;
	reg [1:0] rState = 0;

	reg rwFlag = 0;			// read active low
	reg pktValid = 0;
	reg [31:0] opAddr = 0;
	reg [31:0] opData = 0;
	reg [31:0] oprData = 0;
	reg waitToResp = 0;
	reg axiOpStart = 0;
	reg axiCmpl = 0;
	reg axiErr = 0;

	reg awvalid_int = 0;
	reg [31:0] awaddr_int = 0;
	reg wvalid_int = 0;
	reg [31:0] wdata_int = 0;
	reg bready_int = 0;
	reg arvalid_int = 0;
	reg [31:0] araddr_int = 0;
	reg rready_int = 0;
	reg [1:0] axiState;

	wire [31:0] opRetData;
	wire [31:0] opRetTail;

	assign opRetData = rwFlag?opData:oprData;
	assign opRetTail = pktValid?(axiErr?32'he0e0e0e0:32'h8b8b6d6d):32'he1e1e1e1;

	assign CHNL_RX_CLK = CHNL_CLK;
	assign CHNL_RX_ACK = (rState == 2'd1);
	assign CHNL_RX_DATA_REN = (rState == 2'd1);

	assign CHNL_TX_CLK = CHNL_CLK;
	assign CHNL_TX = (rState == 2'd3);
	assign CHNL_TX_LAST = 1'd1;
	assign CHNL_TX_LEN = 32'd4; // in words
	assign CHNL_TX_OFF = 0;
	assign CHNL_TX_DATA = tData;
	assign CHNL_TX_DATA_VALID = (rState == 2'd3);

	always @(posedge CHNL_CLK) 
		if (!RST_N) begin
			rLen   <= 0;
			rCount <= 0;
			tCount <= 0;
			rData  <= 0;
			tData  <= 0;
			rState <= 0;
		end
		else 
			(* full_case, parallel_case *)case (rState)
				2'd0 : begin // Wait for start of RX, save length
					if(CHNL_RX) begin
						rLen   <= CHNL_RX_LEN;
						rCount <= 0;
						rState <= 2'd1;
					end
				end

				2'd1 : begin // Wait for last data in RX, save value
					if(CHNL_RX_DATA_VALID) begin
						rData  <= CHNL_RX_DATA;
						rCount <= rCount + (C_PCI_DATA_WIDTH/32);
					end
					if(rCount >= rLen)
						rState <= 2'd2;
				end

				2'd2: begin // Prepare for TX
					if(waitToResp) begin
						tCount <= (C_PCI_DATA_WIDTH/32);
						tData <= {opRetTail, opRetData, opAddr, 32'h7f7f5e5e};
						rState <= 2'd3;
					end
					else begin
						tCount <= (C_PCI_DATA_WIDTH/32);
						rState <= 2'd2;
					end
				end

				2'd3: begin // Start TX with save length and data value
					if(CHNL_TX_DATA_REN & CHNL_TX_DATA_VALID) begin
						//tData <= {rCount + 4, rCount + 3, rCount + 2, rCount + 1};
						`ifdef C_PCI_DATA_WIDTH_32
							case(tCount)
								1 : tData <= opAddr;		// C_PCI_DATA_WIDTH IS 32 OpAddr
								2 : tData <= opRetData;		// C_PCI_DATA_WIDTH IS 32 OpData
								3 : tData <= opRetTail; 	// C_PCI_DATA_WIDTH IS 32 Tail
								default : tData <= tData;
							endcase
						`endif
						`ifdef C_PCI_DATA_WIDTH_64
							case(tCount)
								2 : tData <= {opRetTail, opRetData}; // C_PCI_DATA_WIDTH IS 64 [Tail, OpData]
								default : tData <= tData;
							endcase
						`endif
						`ifdef C_PCI_DATA_WIDTH_128
							tData <= {opRetTail, opRetData, opAddr, 32'h7f7f5e5e};
						`endif
						tCount <= tCount + (C_PCI_DATA_WIDTH/32);
						if(tCount >= 4)
							rState <= 2'd0;
					end
				end
			endcase
	
	// parse command packet
	always @ (posedge CHNL_CLK)		// parse read or write
		if(!RST_N) begin
			rwFlag <= 0;
			pktValid <= 0;
		end
		else begin 
			(* full_case, parallel_case *)case(rState)
				0 : begin
					rwFlag <= rwFlag;
					pktValid <= 0;
				end
				1 : begin
					if((rCount==0)&&CHNL_RX_DATA_VALID) begin
						if(CHNL_RX_DATA[31:0]==32'h87873d3d) begin // write operation head
							rwFlag <= 1;
							pktValid <= 1;
						end
						else if(CHNL_RX_DATA[31:0]==32'h98984e4e) begin // read operation head
							rwFlag <= 0;
							pktValid <= 1;
						end
						else begin
							rwFlag <= rwFlag;
							pktValid <= 0;
						end
					end
					else begin
						rwFlag <= rwFlag;
						pktValid <= pktValid;
					end
				end
				default : begin
					rwFlag <= rwFlag;
					pktValid <= pktValid;
				end
			endcase
		end

	always @ (posedge CHNL_CLK) // parse operate addr
		if(!RST_N)
			opAddr <= 0;
		else begin
			`ifdef C_PCI_DATA_WIDTH_32
				if((rState == 2'd1)&&(rCount==1)&&CHNL_RX_DATA_VALID)
					opAddr <= CHNL_RX_DATA[31:0];
				else
					opAddr <= opAddr;
			`else  // C_PCI_DATA_WIDTH IS 64 OR 128
				if((rState == 2'd1)&&(rCount==0)&&CHNL_RX_DATA_VALID)
					opAddr <= CHNL_RX_DATA[63:32];
				else
					opAddr <= opAddr;
			`endif
		end

	always @ (posedge CHNL_CLK) // parse operate data
		if(!RST_N)
			opData <= 0;
		else begin
			`ifdef C_PCI_DATA_WIDTH_32
				if((rState == 2'd1)&&(rCount==2)&&CHNL_RX_DATA_VALID)
					opData <= CHNL_RX_DATA[31:0];
				else
					opData <= opData;
			`endif
			`ifdef C_PCI_DATA_WIDTH_64
				if((rState == 2'd1)&&(rCount==2)&&CHNL_RX_DATA_VALID)
					opData <= CHNL_RX_DATA[31:0];
				else
					opData <= opData;
			`endif
			`ifdef C_PCI_DATA_WIDTH_128
				if((rState == 2'd1)&&(rCount==0)&&CHNL_RX_DATA_VALID)
					opData <= CHNL_RX_DATA[95:64];
				else
					opData <= opData;
			`endif

		end

	always @ (posedge CHNL_CLK) // response operation
		if(!RST_N) begin
			axiOpStart <= 0;
			waitToResp <= 0;
		end
		else 
			casex({rState, axiCmpl, pktValid})
				4'b1000 : begin 	// packet error to resp
					axiOpStart <= 0;
					waitToResp <= 1;
				end
				4'b1001 : begin 	// packet read valid to wait axi read
					axiOpStart <= 1;
					waitToResp <= 0;
				end
				4'b1011 : begin		// read finish to response pcie
					axiOpStart <= 0;
					waitToResp <= 1;
				end
				4'b11xx : begin		// responsed to deassert response signal
					axiOpStart <= 0;
					waitToResp <= 0;
				end
				default : begin
					axiOpStart <= axiOpStart;
					waitToResp <= waitToResp;
				end
			endcase // {rState, axiCmpl, pktValid}

	// axi write or read operation
	always @ (posedge CHNL_CLK)
		if(!RST_N) begin
			awvalid_int <= 0;
			awaddr_int <= 0;
			wvalid_int <= 0;
			wdata_int <= 0;
			bready_int <= 0;
			arvalid_int <= 0;
			araddr_int <= 0;
			rready_int <= 0;
			axiCmpl <= 0;
			axiErr <= 0;
			axiState <= 0;
		end
		else
			(* full_case, parallel_case *)case (axiState)
				0 : if(axiOpStart) begin
						axiCmpl <= 0;
						axiErr <= 0;
						axiState <= 1;
						if(rwFlag) begin // write op
							awvalid_int <= 1;
							awaddr_int <= opAddr;
							wvalid_int <= 1;
							wdata_int <= opData;
							bready_int <= 1;
						end
						else begin
							arvalid_int <= 1;
							araddr_int <= opAddr;
							rready_int <= 1;
						end
					end
					else begin
						awvalid_int <= 0;
						awaddr_int <= 0;
						wvalid_int <= 0;
						wdata_int <= 0;
						bready_int <= 0;
						arvalid_int <= 0;
						araddr_int <= 0;
						rready_int <= 0;
						axiCmpl <= 0;
						axiErr <= 0;
						axiState <= 0;		
					end

				1 : begin
						if(rwFlag) begin // write op
							if(awvalid_int&&cmd_m_axi_awready)
								awvalid_int <= 0;
							else 
								awvalid_int <= awvalid_int;
							if(wvalid_int&&cmd_m_axi_wready)
								wvalid_int <= 0;
							else 
								wvalid_int <= wvalid_int;
							if({bready_int, cmd_m_axi_bvalid}==2'b11) begin
								if(cmd_m_axi_bresp==2'b00) begin
									axiCmpl <= 1;
									axiErr <= 0;
									axiState <= 2;
								end
								else begin
									axiCmpl <= 1;
									axiErr <= 1;
									axiState <= 2;
								end
							end
							else begin
								axiCmpl <= 0;
								axiErr <= 0;
								axiState <= 1;
							end
						end
						else begin
							if(arvalid_int&&cmd_m_axi_arready)
								arvalid_int <= 0;
							else 
								arvalid_int <= arvalid_int;
							if(cmd_m_axi_rvalid&&rready_int) begin
								axiCmpl <= 1;
								axiErr <= 0;
								axiState <= 2;
							end
							else begin
								axiCmpl <= 0;
								axiErr <= 0;
								axiState <= 1;
							end
						end
					end
				2 : begin
						axiCmpl <= 1;
						axiErr <= 0;
						axiState <= 3;
					end
				default : begin
						awvalid_int <= 0;
						awaddr_int <= 0;
						wvalid_int <= 0;
						wdata_int <= 0;
						bready_int <= 0;
						arvalid_int <= 0;
						araddr_int <= 0;
						rready_int <= 0;
						axiCmpl <= 0;
						axiErr <= 0;
						axiState <= 0;
					end
				
			endcase

	always @ (posedge CHNL_CLK) // parse operate addr
		if(!RST_N)
			oprData <= 0;
		else begin
			if(cmd_m_axi_rvalid&&rready_int) 
				oprData <= cmd_m_axi_rdata;
			else
				oprData <= oprData;
		end

	assign cmd_m_axi_awvalid = awvalid_int;
	assign cmd_m_axi_awaddr = awaddr_int;
	assign cmd_m_axi_wvalid = wvalid_int;
	assign cmd_m_axi_wdata = wdata_int;
	assign cmd_m_axi_bready = bready_int;
	assign cmd_m_axi_arvalid = arvalid_int;
	assign cmd_m_axi_araddr = araddr_int;
	assign cmd_m_axi_rready = rready_int;
	assign cmd_m_axi_wstrb = 4'b1111;

endmodule