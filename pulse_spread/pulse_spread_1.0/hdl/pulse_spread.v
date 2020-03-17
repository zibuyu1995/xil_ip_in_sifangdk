// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : pulse_spread.v
// Create : 2020-03-17 11:04:20
// Revised: 2020-03-17 11:12:16
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module pulse_spread #(
		parameter WIDTH    = 6     ,
		parameter POLARITY = "HIGH"
	) (
		input  clk       , // Clock
		input  rst_n     , // Synchronous reset active low
		//
		input  signal    ,
		//
		output signal_out
	);

	reg [WIDTH-1:0] shift_reg;
	reg pulse_hit;

	generate
		if(POLARITY == "HIGH") begin
			always @ (posedge clk)
				if(!rst_n) begin
					shift_reg <= 0;
					pulse_hit <= 0;
				end
			else begin
				shift_reg <= {shift_reg[WIDTH-2:0], signal};
				pulse_hit <= |shift_reg;
			end
		end
		else begin
			always @ (posedge clk)
				if(!rst_n) begin
					shift_reg <= {WIDTH{1'b1}};
					pulse_hit <= 1;
				end
			else begin
				shift_reg <= {shift_reg[WIDTH-2:0], signal};
				pulse_hit <= &shift_reg;
			end
		end
	endgenerate


endmodule