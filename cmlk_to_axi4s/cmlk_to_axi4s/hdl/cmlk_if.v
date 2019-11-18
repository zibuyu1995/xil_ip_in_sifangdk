// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk_if.v
// Create : 2019-09-20 09:44:39
// Revised: 2019-10-22 13:46:03
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cmlk_if(
		input clk,
		input rst_n,
		// cmlk interface 
		input cmlk_clk_x,
		input [27:0] cmlk_data_x, 
		input cmlk_clk_y,
		input [27:0] cmlk_data_y,
		input cmlk_clk_z,
		input [27:0] cmlk_data_z,
		// cmlk data out to same clock domain
		output [27:0] cmlk_data_x_o,
		output [27:0] cmlk_data_y_o,
		output [27:0] cmlk_data_z_o,
		output cmlk_data_valid_o
	);

	genvar inst;

	wire cmlk_clk_x_ibuf;
	wire cmlk_clk_x_bufr;

	wire cmlk_clk_y_ibuf;
	wire cmlk_clk_y_bufr;

	wire cmlk_clk_z_ibuf;
	wire cmlk_clk_z_bufmr;
	wire cmlk_clk_z_bufr_0;
	wire cmlk_clk_z_bufr_1;

	wire [27:0] cmlk_data_x_ibuf;
	wire [27:0] cmlk_data_x_r;
	wire [27:0] cmlk_data_y_ibuf;
	wire [27:0] cmlk_data_y_r;
	wire [27:0] cmlk_data_z_ibuf;
	wire [27:0] cmlk_data_z_r;

	wire [55:0] cmlk_data_x_fq;
	wire [55:0] cmlk_data_y_fq;
	wire [55:0] cmlk_data_z_fq;
	wire cmlk_data_x_empty;
	wire cmlk_data_y_empty;
	wire cmlk_data_z_empty_0;
	wire cmlk_data_z_empty_1;

	wire [27:0] cmlk_data_x_s;
	wire [27:0] cmlk_data_y_s;
	wire [27:0] cmlk_data_z_s;
	wire cmlk_data_rden;

	reg [27:0] cmlk_data_x_q;
	reg [27:0] cmlk_data_y_q;
	reg [27:0] cmlk_data_z_q;
	reg cmlk_data_valid;

	// cameralink x clk
	IBUF ibuf_cmlk_clk_x_i0 (
		.O(cmlk_clk_x_ibuf), // Buffer output
		.I(cmlk_clk_x     )  // Buffer input (connect directly to top-level port)
	);

	BUFR bufr_cmlk_clk_x_i0 (
		.O  (cmlk_clk_x_bufr), // 1-bit output: Clock output port
		.CE (1'b1           ), // 1-bit input: Active high, clock enable (Divided modes only)
		.CLR(1'b0           ), // 1-bit input: Active high, asynchronous clear (Divided modes only)
		.I  (cmlk_clk_x_ibuf)  // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
	);

	// cameralink y clk
	IBUF ibuf_cmlk_clk_y_i0 (
		.O(cmlk_clk_y_ibuf), // Buffer output
		.I(cmlk_clk_y     )  // Buffer input (connect directly to top-level port)
	);

	BUFR bufr_cmlk_clk_y_i0 (
		.O  (cmlk_clk_y_bufr), // 1-bit output: Clock output port
		.CE (1'b1           ), // 1-bit input: Active high, clock enable (Divided modes only)
		.CLR(1'b0           ), // 1-bit input: Active high, asynchronous clear (Divided modes only)
		.I  (cmlk_clk_y_ibuf)  // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
	);

	// cameralink z clk
	IBUF ibuf_cmlk_clk_z_i0 (
		.O(cmlk_clk_z_ibuf), // Buffer output
		.I(cmlk_clk_z     )  // Buffer input (connect directly to top-level port)
	);

	BUFMR bufmr_cmlk_clk_z_i0 (
		.O(cmlk_clk_z_bufmr), // 1-bit output: Clock output (connect to BUFIOs/BUFRs)
		.I(cmlk_clk_z_ibuf )  // 1-bit input: Clock input (Connect to IBUF)
	);

	BUFR bufr_cmlk_clk_z_i0 (
		.O  (cmlk_clk_z_bufr_0), // 1-bit output: Clock output port
		.CE (1'b1             ), // 1-bit input: Active high, clock enable (Divided modes only)
		.CLR(1'b0             ), // 1-bit input: Active high, asynchronous clear (Divided modes only)
		.I  (cmlk_clk_z_bufmr )  // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
	);

	BUFR bufr_cmlk_clk_z_i1 (
		.O  (cmlk_clk_z_bufr_1), // 1-bit output: Clock output port
		.CE (1'b1             ), // 1-bit input: Active high, clock enable (Divided modes only)
		.CLR(1'b0             ), // 1-bit input: Active high, asynchronous clear (Divided modes only)
		.I  (cmlk_clk_z_bufmr )  // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
	);


	// cmlk data x sample
	generate
		for(inst=0; inst<28; inst=inst+1) begin : cmlk_smpl_x
			IBUF ibuf_cmlk_data_x_i (
				.O(cmlk_data_x_ibuf[inst]), // Buffer output
				.I(cmlk_data_x[inst]     )  // Buffer input (connect directly to top-level port)
			);
			(* IOB="true" *)FDRE fdre_cmlk_data_x_i (
				.Q (cmlk_data_x_r[inst]   ), // 1-bit Data output
				.C (cmlk_clk_x_bufr       ), // 1-bit Clock input
				.CE(1'b1                  ), // 1-bit Clock enable input
				.R (1'b0                  ), // 1-bit Synchronous reset input
				.D (cmlk_data_x_ibuf[inst])  // 1-bit Data input
			);
		end
	endgenerate

	// cmlk data y sample
	generate
		for(inst=0; inst<28; inst=inst+1) begin : cmlk_smpl_y
			IBUF ibuf_cmlk_data_y_i (
				.O(cmlk_data_y_ibuf[inst]), // Buffer output
				.I(cmlk_data_y[inst]     )  // Buffer input (connect directly to top-level port)
			);
			(* IOB="true" *)FDRE fdre_cmlk_data_y_i (
				.Q (cmlk_data_y_r[inst]   ), // 1-bit Data output
				.C (cmlk_clk_y_bufr       ), // 1-bit Clock input
				.CE(1'b1                  ), // 1-bit Clock enable input
				.R (1'b0                  ), // 1-bit Synchronous reset input
				.D (cmlk_data_y_ibuf[inst])  // 1-bit Data input
			);
		end
	endgenerate

	// cmlk data z sample
	generate
		for(inst=0; inst<28; inst=inst+1) begin : cmlk_smpl_z
			// bank 13
			if(((inst>=0)&&(inst<=9))||(inst==11)||(inst==12)) begin
				IBUF ibuf_cmlk_data_z_i (
					.O(cmlk_data_z_ibuf[inst]), // Buffer output
					.I(cmlk_data_z[inst]     )  // Buffer input (connect directly to top-level port)
				);
				(* IOB="true" *)FDRE fdre_cmlk_data_z_i (
					.Q (cmlk_data_z_r[inst]   ), // 1-bit Data output
					.C (cmlk_clk_z_bufr_0     ), // 1-bit Clock input
					.CE(1'b1                  ), // 1-bit Clock enable input
					.R (1'b0                  ), // 1-bit Synchronous reset input
					.D (cmlk_data_z_ibuf[inst])  // 1-bit Data input
				);
			end
			// bank 12
			else begin
				IBUF ibuf_cmlk_data_z_i (
					.O(cmlk_data_z_ibuf[inst]), // Buffer output
					.I(cmlk_data_z[inst]     )  // Buffer input (connect directly to top-level port)
				);
				(* IOB="true" *)FDRE fdre_cmlk_data_z_i (
					.Q (cmlk_data_z_r[inst]   ), // 1-bit Data output
					.C (cmlk_clk_z_bufr_1     ), // 1-bit Clock input
					.CE(1'b1                  ), // 1-bit Clock enable input
					.R (1'b0                  ), // 1-bit Synchronous reset input
					.D (cmlk_data_z_ibuf[inst])  // 1-bit Data input
				);
			end
		end
	endgenerate

	// cmlk synchronize x
	IN_FIFO #(
		.ALMOST_EMPTY_VALUE(1                 ), // Almost empty offset (1-2)
		.ALMOST_FULL_VALUE (1                 ), // Almost full offset (1-2)
		.ARRAY_MODE        ("ARRAY_MODE_4_X_4"), // ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
		.SYNCHRONOUS_MODE  ("FALSE"           )  // Clock synchronous (FALSE)
	) in_fifo_cmlk_x_i0 (
		// FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
		.ALMOSTEMPTY(                     ), // 1-bit output: Almost empty
		.ALMOSTFULL (                     ), // 1-bit output: Almost full
		.EMPTY      (cmlk_data_x_empty    ), // 1-bit output: Empty
		.FULL       (                     ), // 1-bit output: Full
		// Q0-Q9: 8-bit (each) output: FIFO Outputs
		.Q0         (cmlk_data_x_fq[7:0]  ), // 8-bit output: Channel 0
		.Q1         (cmlk_data_x_fq[15:8] ), // 8-bit output: Channel 1
		.Q2         (cmlk_data_x_fq[23:16]), // 8-bit output: Channel 2
		.Q3         (cmlk_data_x_fq[31:24]), // 8-bit output: Channel 3
		.Q4         (cmlk_data_x_fq[39:32]), // 8-bit output: Channel 4
		.Q5         (                     ), // 8-bit output: Channel 5
		.Q6         (                     ), // 8-bit output: Channel 6
		.Q7         (cmlk_data_x_fq[47:40]), // 8-bit output: Channel 7
		.Q8         (cmlk_data_x_fq[55:48]), // 8-bit output: Channel 8
		.Q9         (                     ), // 8-bit output: Channel 9
		// D0-D9: 4-bit (each) input: FIFO inputs
		.D0         (cmlk_data_x_r[3:0]   ), // 4-bit input: Channel 0
		.D1         (cmlk_data_x_r[7:4]   ), // 4-bit input: Channel 1
		.D2         (cmlk_data_x_r[11:8]  ), // 4-bit input: Channel 2
		.D3         (cmlk_data_x_r[15:12] ), // 4-bit input: Channel 3
		.D4         (cmlk_data_x_r[19:16] ), // 4-bit input: Channel 4
		.D5         (8'd0                 ), // 8-bit input: Channel 5
		.D6         (8'd0                 ), // 8-bit input: Channel 6
		.D7         (cmlk_data_x_r[23:20] ), // 4-bit input: Channel 7
		.D8         (cmlk_data_x_r[27:24] ), // 4-bit input: Channel 8
		.D9         (4'd0                 ), // 4-bit input: Channel 9
		// FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
		.RDCLK      (clk                  ), // 1-bit input: Read clock
		.RDEN       (cmlk_data_rden       ), // 1-bit input: Read enable
		.RESET      (~rst_n               ), // 1-bit input: Reset
		.WRCLK      (cmlk_clk_x_bufr      ), // 1-bit input: Write clock
		.WREN       (1'b1                 )  // 1-bit input: Write enable
	);

	assign cmlk_data_x_s[3:0] = cmlk_data_x_fq[3:0];
	assign cmlk_data_x_s[7:4] = cmlk_data_x_fq[11:8];
	assign cmlk_data_x_s[11:8] = cmlk_data_x_fq[19:16];
	assign cmlk_data_x_s[15:12] = cmlk_data_x_fq[27:24];
	assign cmlk_data_x_s[19:16] = cmlk_data_x_fq[35:32];
	assign cmlk_data_x_s[23:20] = cmlk_data_x_fq[43:40];
	assign cmlk_data_x_s[27:24] = cmlk_data_x_fq[51:48];

	// cmlk synchronize y
	IN_FIFO #(
		.ALMOST_EMPTY_VALUE(1                 ), // Almost empty offset (1-2)
		.ALMOST_FULL_VALUE (1                 ), // Almost full offset (1-2)
		.ARRAY_MODE        ("ARRAY_MODE_4_X_4"), // ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
		.SYNCHRONOUS_MODE  ("FALSE"           )  // Clock synchronous (FALSE)
	) in_fifo_cmlk_y_i0 (
		// FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
		.ALMOSTEMPTY(                     ), // 1-bit output: Almost empty
		.ALMOSTFULL (                     ), // 1-bit output: Almost full
		.EMPTY      (cmlk_data_y_empty    ), // 1-bit output: Empty
		.FULL       (                     ), // 1-bit output: Full
		// Q0-Q9: 8-bit (each) output: FIFO Outputs
		.Q0         (cmlk_data_y_fq[7:0]  ), // 8-bit output: Channel 0
		.Q1         (cmlk_data_y_fq[15:8] ), // 8-bit output: Channel 1
		.Q2         (cmlk_data_y_fq[23:16]), // 8-bit output: Channel 2
		.Q3         (cmlk_data_y_fq[31:24]), // 8-bit output: Channel 3
		.Q4         (cmlk_data_y_fq[39:32]), // 8-bit output: Channel 4
		.Q5         (                     ), // 8-bit output: Channel 5
		.Q6         (                     ), // 8-bit output: Channel 6
		.Q7         (cmlk_data_y_fq[47:40]), // 8-bit output: Channel 7
		.Q8         (cmlk_data_y_fq[55:48]), // 8-bit output: Channel 8
		.Q9         (                     ), // 8-bit output: Channel 9
		// D0-D9: 4-bit (each) input: FIFO inputs
		.D0         (cmlk_data_y_r[3:0]   ), // 4-bit input: Channel 0
		.D1         (cmlk_data_y_r[7:4]   ), // 4-bit input: Channel 1
		.D2         (cmlk_data_y_r[11:8]  ), // 4-bit input: Channel 2
		.D3         (cmlk_data_y_r[15:12] ), // 4-bit input: Channel 3
		.D4         (cmlk_data_y_r[19:16] ), // 4-bit input: Channel 4
		.D5         (8'd0                 ), // 8-bit input: Channel 5
		.D6         (8'd0                 ), // 8-bit input: Channel 6
		.D7         (cmlk_data_y_r[23:20] ), // 4-bit input: Channel 7
		.D8         (cmlk_data_y_r[27:24] ), // 4-bit input: Channel 8
		.D9         (4'd0                 ), // 4-bit input: Channel 9
		// FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
		.RDCLK      (clk                  ), // 1-bit input: Read clock
		.RDEN       (cmlk_data_rden       ), // 1-bit input: Read enable
		.RESET      (~rst_n               ), // 1-bit input: Reset
		.WRCLK      (cmlk_clk_y_bufr      ), // 1-bit input: Write clock
		.WREN       (1'b1                 )  // 1-bit input: Write enable
	);

	assign cmlk_data_y_s[3:0] = cmlk_data_y_fq[3:0];
	assign cmlk_data_y_s[7:4] = cmlk_data_y_fq[11:8];
	assign cmlk_data_y_s[11:8] = cmlk_data_y_fq[19:16];
	assign cmlk_data_y_s[15:12] = cmlk_data_y_fq[27:24];
	assign cmlk_data_y_s[19:16] = cmlk_data_y_fq[35:32];
	assign cmlk_data_y_s[23:20] = cmlk_data_y_fq[43:40];
	assign cmlk_data_y_s[27:24] = cmlk_data_y_fq[51:48];

	// cmlk synchronize z
	IN_FIFO #(
		.ALMOST_EMPTY_VALUE(1                 ), // Almost empty offset (1-2)
		.ALMOST_FULL_VALUE (1                 ), // Almost full offset (1-2)
		.ARRAY_MODE        ("ARRAY_MODE_4_X_4"), // ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
		.SYNCHRONOUS_MODE  ("FALSE"           )  // Clock synchronous (FALSE)
	) in_fifo_cmlk_z_i0 (
		// FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
		.ALMOSTEMPTY(                      ), // 1-bit output: Almost empty
		.ALMOSTFULL (                      ), // 1-bit output: Almost full
		.EMPTY      (cmlk_data_z_empty_0   ), // 1-bit output: Empty
		.FULL       (                      ), // 1-bit output: Full
		// Q0-Q9: 8-bit (each) output: FIFO Outputs
		.Q0         (cmlk_data_z_fq[7:0]   ), // 8-bit output: Channel 0
		.Q1         (cmlk_data_z_fq[15:8]  ), // 8-bit output: Channel 1
		.Q2         ({cmlk_data_z_fq[28], cmlk_data_z_fq[23], cmlk_data_z_fq[21:20], cmlk_data_z_fq[24], cmlk_data_z_fq[19], cmlk_data_z_fq[17:16]}), // 8-bit output: Channel 2
		.Q3         (                      ), // 8-bit output: Channel 3
		.Q4         (                      ), // 8-bit output: Channel 4
		.Q5         (                      ), // 8-bit output: Channel 5
		.Q6         (                      ), // 8-bit output: Channel 6
		.Q7         (                      ), // 8-bit output: Channel 7
		.Q8         (                      ), // 8-bit output: Channel 8
		.Q9         (                      ), // 8-bit output: Channel 9
		// D0-D9: 4-bit (each) input: FIFO inputs
		.D0         (cmlk_data_z_r[3:0]    ), // 4-bit input: Channel 0
		.D1         (cmlk_data_z_r[7:4]    ), // 4-bit input: Channel 1
		.D2         ({cmlk_data_z_r[12:11], cmlk_data_z_r[9:8]}), // 4-bit input: Channel 2
		.D3         (4'd0                  ), // 4-bit input: Channel 3
		.D4         (4'd0                  ), // 4-bit input: Channel 4
		.D5         (8'd0                  ), // 8-bit input: Channel 5
		.D6         (8'd0                  ), // 8-bit input: Channel 6
		.D7         (4'd0                  ), // 4-bit input: Channel 7
		.D8         (4'd0                  ), // 4-bit input: Channel 8
		.D9         (4'd0                  ), // 4-bit input: Channel 9
		// FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
		.RDCLK      (clk                   ), // 1-bit input: Read clock
		.RDEN       (cmlk_data_rden        ), // 1-bit input: Read enable
		.RESET      (~rst_n                ), // 1-bit input: Reset
		.WRCLK      (cmlk_clk_z_bufr_0     ), // 1-bit input: Write clock
		.WREN       (1'b1                  )  // 1-bit input: Write enable
	);

	IN_FIFO #(
		.ALMOST_EMPTY_VALUE(1                 ), // Almost empty offset (1-2)
		.ALMOST_FULL_VALUE (1                 ), // Almost full offset (1-2)
		.ARRAY_MODE        ("ARRAY_MODE_4_X_4"), // ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
		.SYNCHRONOUS_MODE  ("FALSE"           )  // Clock synchronous (FALSE)
	) in_fifo_cmlk_z_i1 (
		// FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
		.ALMOSTEMPTY(                     ), // 1-bit output: Almost empty
		.ALMOSTFULL (                     ), // 1-bit output: Almost full
		.EMPTY      (cmlk_data_z_empty_1  ), // 1-bit output: Empty
		.FULL       (                     ), // 1-bit output: Full
		// Q0-Q9: 8-bit (each) output: FIFO Outputs
		.Q0         ({cmlk_data_z_fq[31:29], cmlk_data_z_fq[22], cmlk_data_z_fq[27:25], cmlk_data_z_fq[18]}), // 8-bit output: Channel 0
		.Q1         (cmlk_data_z_fq[39:32]), // 8-bit output: Channel 1
		.Q2         (cmlk_data_z_fq[47:40]), // 8-bit output: Channel 2
		.Q3         (cmlk_data_z_fq[55:48]), // 8-bit output: Channel 3
		.Q4         (                     ), // 8-bit output: Channel 4
		.Q5         (                     ), // 8-bit output: Channel 5
		.Q6         (                     ), // 8-bit output: Channel 6
		.Q7         (                     ), // 8-bit output: Channel 7
		.Q8         (                     ), // 8-bit output: Channel 8
		.Q9         (                     ), // 8-bit output: Channel 9
		// D0-D9: 4-bit (each) input: FIFO inputs
		.D0         ({cmlk_data_z_r[15:13], cmlk_data_z_r[10]}), // 4-bit input: Channel 0
		.D1         (cmlk_data_z_r[19:16] ), // 4-bit input: Channel 1
		.D2         (cmlk_data_z_r[23:20] ), // 4-bit input: Channel 2
		.D3         (cmlk_data_z_r[27:24] ), // 4-bit input: Channel 3
		.D4         (4'd0                 ), // 4-bit input: Channel 4
		.D5         (8'd0                 ), // 8-bit input: Channel 5
		.D6         (8'd0                 ), // 8-bit input: Channel 6
		.D7         (4'd0                 ), // 4-bit input: Channel 7
		.D8         (4'd0                 ), // 4-bit input: Channel 8
		.D9         (4'd0                 ), // 4-bit input: Channel 9
		// FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
		.RDCLK      (clk                  ), // 1-bit input: Read clock
		.RDEN       (cmlk_data_rden       ), // 1-bit input: Read enable
		.RESET      (~rst_n               ), // 1-bit input: Reset
		.WRCLK      (cmlk_clk_z_bufr_1    ), // 1-bit input: Write clock
		.WREN       (1'b1                 )  // 1-bit input: Write enable
	);

	assign cmlk_data_z_s[3:0] = cmlk_data_z_fq[3:0];
	assign cmlk_data_z_s[7:4] = cmlk_data_z_fq[11:8];
	assign cmlk_data_z_s[11:8] = cmlk_data_z_fq[19:16];
	assign cmlk_data_z_s[15:12] = cmlk_data_z_fq[27:24];
	assign cmlk_data_z_s[19:16] = cmlk_data_z_fq[35:32];
	assign cmlk_data_z_s[23:20] = cmlk_data_z_fq[43:40];
	assign cmlk_data_z_s[27:24] = cmlk_data_z_fq[51:48];

	// cmlk data preprocessing
	assign cmlk_data_rden = ({cmlk_data_z_empty_1, cmlk_data_z_empty_0, cmlk_data_y_empty, cmlk_data_x_empty}==4'b0000);

	always @ (posedge clk)
		if(!rst_n) begin
			cmlk_data_x_q <= 0;
			cmlk_data_y_q <= 0;
			cmlk_data_z_q <= 0;
			cmlk_data_valid <= 0;
		end
		else begin
			cmlk_data_x_q <= cmlk_data_x_s;
			cmlk_data_y_q <= cmlk_data_y_s;
			cmlk_data_z_q <= cmlk_data_z_s;
			cmlk_data_valid <= cmlk_data_rden;
		end

	assign cmlk_data_x_o = cmlk_data_x_q;
	assign cmlk_data_y_o = cmlk_data_y_q;
	assign cmlk_data_z_o = cmlk_data_z_q;
	assign cmlk_data_valid_o = cmlk_data_valid;

endmodule
