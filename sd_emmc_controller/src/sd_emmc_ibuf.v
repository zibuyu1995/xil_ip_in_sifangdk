`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/29 15:52:58
// Design Name: 
// Module Name: sd_emmc_ibuf
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sd_emmc_ibuf #(DATA_WIDTH = 1) (
		output [DATA_WIDTH-1:0] di_o  ,
		input  [DATA_WIDTH-1:0] di_pad
	);

	genvar n;
	generate
		for (n = 0; n < DATA_WIDTH; n = n + 1) begin: g_ibuf
			IBUF IBUF_i (
				.O(di_o[n]  ), // Buffer output
				.I(di_pad[n])  // Buffer input (connect directly to top-level port)
			);
		end
	endgenerate

endmodule
