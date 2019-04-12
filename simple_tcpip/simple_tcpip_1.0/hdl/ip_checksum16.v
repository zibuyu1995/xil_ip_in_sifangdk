// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : ip_checksum16.v
// Create : 2019-04-12 23:06:36
// Editor : sublime text3, tab size (4)
// Coding : utf-8
// -----------------------------------------------------------------------------
module ip_checksum16 (
	input  wire        clk        , // Clock
	input  wire        rst_n      , // Asynchronous reset active low
	input  wire [15:0] pkt_len    , //packet length (udp or tcp len + ip head)
	input  wire [31:0] src_ip     ,
	input  wire [31:0] dst_ip     ,
	output wire [15:0] ip_checksum
);

	parameter ID = 32'hB3FE;	//Identification
	parameter TTL = 8'h80;		//Time To Live
	parameter PROTOCOL = 8'h11; 	//0x11---UDP  0x06---TCP

	localparam STAGE1C_P0 = ID + {16'd0, TTL, PROTOCOL};
	localparam STAGE1C_P1 = 32'h4500;
	localparam STAGE1C_A0 = STAGE1C_P0 + STAGE1C_P1;

	//register define
	reg [31:0] pipeline_stage1a;
	reg [31:0] pipeline_stage1b;
	reg [31:0] pipeline_stage1c;
	reg [31:0] pipeline_stage2;
	reg [15:0] pipeline_stage3;
	reg [15:0] ip_checksum_r;

	//pipeline stage 1
	always @ (posedge clk)
		if(!rst_n) begin
			pipeline_stage1a <= 0;
			pipeline_stage1b <= 0;
			pipeline_stage1c <= 0;
		end
		else begin
			pipeline_stage1a <= {16'd0, src_ip[15:0]} + {16'd0, src_ip[31:16]};
			pipeline_stage1b <= {16'd0, dst_ip[15:0]} + {16'd0, dst_ip[31:16]};
			pipeline_stage1c <= STAGE1C_A0 + {16'd0, pkt_len};
		end

	//pipeline stage 2
	always @ (posedge clk)
		if(!rst_n) begin
			pipeline_stage2 <= 0;
		end
		else begin
			pipeline_stage2 <= pipeline_stage1a + pipeline_stage1b + pipeline_stage1c;
		end

	//pipeline stage 3
	always @ (posedge clk)
		if(!rst_n) begin
			pipeline_stage3 <= 0;
		end
		else begin
			pipeline_stage3 <= pipeline_stage2[15:0] + pipeline_stage2[31:16];
		end

	//pipeline stage 4
	always @ (posedge clk)
		if(!rst_n) begin
			ip_checksum_r <= 0;
		end
		else begin
			ip_checksum_r <= ~pipeline_stage3;
		end

	assign ip_checksum = ip_checksum_r;

endmodule