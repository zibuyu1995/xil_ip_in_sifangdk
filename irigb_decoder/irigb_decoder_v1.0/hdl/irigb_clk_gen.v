// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : system_top.v
// Create : 2019-05-10 17:30:21
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module irigb_clk_gen #(parameter CLKFREQ = 100_000_000) (
		input  rst, clk     ,
		output clk_10KHz_out,
		output clk_1KHz_out
	);

	localparam HALF_10KHZ = CLKFREQ / 10_000 / 2;
	localparam JUST_10KHZ = CLKFREQ / 10_000;
	localparam DIVIDER_10 = 10;

	reg clk_10KHz;
	reg clk_1KHz;
	reg [12:0] cnt_10KHz;
	reg [3:0] cnt_div;

	assign clk_10KHz_out = clk_10KHz;
	assign clk_1KHz_out = clk_1KHz;
 
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			cnt_10KHz <= 13'b0;
			cnt_div   <= 4'b0;
			clk_10KHz <= 1'b0;
			clk_1KHz  <= 1'b0;
		end
		else begin
			if(cnt_10KHz == HALF_10KHZ -13'b1) begin
				cnt_10KHz <= 13'b0;
				clk_10KHz <= ~clk_10KHz;
				if(cnt_div == DIVIDER_10 -3'b1) begin
					cnt_div  <= 4'b0;
					clk_1KHz <= ~clk_1KHz;
				end
				else begin
					cnt_div <= cnt_div + 4'b1;
				end
			end
			else begin
				cnt_10KHz <= cnt_10KHz + 13'b1;
			end
		end
	end	

endmodule
