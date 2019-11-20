// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : fifo_if_reorder.v
// Create : 2019-11-20 10:26:45
// Revised: 2019-11-20 16:58:58
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module fifo_if_reorder #(
		parameter IF_TYPE = "WRITE",
		parameter IF_WIDTH = 256,
		parameter DIVISOR = 8
	)(
		// fifo write if a slv
		input [IF_WIDTH-1:0] fifo_a_wrdata,
		input fifo_a_wren,
		output fifo_a_full,
		output fifo_a_almostfull,
		// fifo write if b mst
		output [IF_WIDTH-1:0] fifo_b_wrdata,
		output fifo_b_wren,
		input fifo_b_full,
		input fifo_b_almostfull,
		// fifo read if a slv
		output [IF_WIDTH-1:0] fifo_a_rddata,
		input fifo_a_rden,
		output fifo_a_empty,
		output fifo_a_almostempty,
		// fifo read if b mst
		input [IF_WIDTH-1:0] fifo_b_rddata,
		output fifo_b_rden,
		input fifo_b_empty,
		input fifo_b_almostempty
	);

	localparam BASE_WIDTH_COEF = IF_WIDTH;
	localparam BASE_WIDTH = IF_WIDTH/DIVISOR;

	genvar i;

	generate
		if(IF_TYPE=="WRITE") begin
			assign fifo_b_wren = fifo_a_wren;
			assign fifo_a_full = fifo_b_full;
			assign fifo_a_almostfull = fifo_b_almostfull;
			for(i=0; i<BASE_WIDTH_COEF; i=i+1) begin
				assign fifo_b_wrdata[BASE_WIDTH*i +: BASE_WIDTH] = fifo_a_wrdata[BASE_WIDTH*(BASE_WIDTH_COEF-i-1) +: BASE_WIDTH];
			end
		end
	endgenerate

	generate
		if(IF_TYPE=="READ") begin
			assign fifo_b_rden = fifo_a_rden;
			assign fifo_a_empty = fifo_b_empty;
			assign fifo_a_almostempty = fifo_b_almostempty;
			for(i=0; i<BASE_WIDTH_COEF; i=i+1) begin
				assign fifo_a_rddata[BASE_WIDTH*i +: BASE_WIDTH] = fifo_b_rddata[BASE_WIDTH*(BASE_WIDTH_COEF-i-1) +: BASE_WIDTH];
			end
		end
	endgenerate

endmodule