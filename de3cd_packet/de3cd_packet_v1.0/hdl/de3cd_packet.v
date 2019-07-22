// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : de3cd_packet.v
// Create : 2019-07-18 16:32:31
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module de3cd_packet(
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low
	// data input 10 channel
	input [159:0] tcd1304_din,
	input [9:0] tcd1304_valid,
	input [9:0] tcd1304_frame_start,
	// packet data out
	output [63:0] fifo_1_wdata,
	output fifo_1_wren,
	input fifo_1_wrfull,
	output [63:0] fifo_2_wdata,
	output fifo_2_wren,
	input fifo_2_wrfull,
	// signal indicator
	input prog_1_empty,
	input prog_2_empty,
	// write done signal indicator
	output region_indc,  // 0--Region A, 1--Region B
	output region_valid,
	// misc
	output init_txn
);

	localparam DATA_LEN = 3648 * 5 / 2;

	localparam IDLE = 2'b00;
	localparam WR2FIFO = 2'b01;
	localparam FILLFIFO = 2'b10;
	localparam WRDONE = 2'b11;

	wire [159:0] tcd1304_dout;
	wire tcd1304_rden;
	wire [9:0] tcd1304_rdempty;
	wire tcd1304_fifo_valid;

	reg [319:0] data_cache1 = 320'd0;
	reg [319:0] data_cache2 = 320'd0;
	reg [1:0] data_cache_cnt = 0;
	reg data_cache_sel_r = 0;
	reg data_cache_ready = 0;
	reg data_cache_clr = 0;

	reg [1:0] mst_state = IDLE;
	reg [15:0] internal_cnt = 0;
	reg region_sel_r = 0;

	reg [63:0] wrfifo_data = 0;
	reg wrfifo_wren = 0;
	reg [3:0] internal_cnt2 = 0;

	reg [63:0] fifo_1_wdata_r = 0;
	reg fifo_1_wren_r = 0;
	reg [63:0] fifo_2_wdata_r = 0;
	reg fifo_2_wren_r = 0;
	reg region_indc_int = 0;
	reg region_indc_r = 0;
	reg region_valid_r = 0;

	genvar i;

	assign tcd1304_fifo_valid = (tcd1304_rdempty==10'b0000000000);
	assign tcd1304_rden = tcd1304_fifo_valid;

	generate
		for(i=0; i<10; i=i+1) begin 
			fifo_18k_sync fifo_18k_sync_i(
				.clk     (clk),
				.rst     ((~rst_n)|(tcd1304_frame_start[0])),
				.wren    (tcd1304_valid[i]),
				.wrdata  (tcd1304_din[i*16 +: 16]),
				.wrfull  (),
				.rden    (tcd1304_rden),
				.rddata  (tcd1304_dout[i*16 +: 16]),
				.rdempty (tcd1304_rdempty[i])
			);
		end
	endgenerate
	
	always @ (posedge clk)
		if((rst_n==1'b0)||(tcd1304_frame_start[0])) begin
			data_cache1 <= 0;
			data_cache2 <= 0;
			data_cache_cnt <= 0;
			data_cache_ready <= 0;
			data_cache_sel_r <= 0;
		end
		else begin
			if(tcd1304_fifo_valid) begin
				data_cache_cnt <= data_cache_cnt + 1'b1;
				if(data_cache_cnt[1]==0)
					data_cache1 <= {tcd1304_dout, data_cache1[319:160]};
				else
					data_cache2 <= {tcd1304_dout, data_cache2[319:160]};
			end
			else begin
				data_cache_cnt <= data_cache_cnt;
				data_cache1 <= data_cache1;
				data_cache2 <= data_cache2;
			end

			data_cache_sel_r <= data_cache_cnt[1];
			// if(tcd1304_fifo_valid)
			// 	data_cache_sel_r <= data_cache_cnt[1];
			// else
			// 	data_cache_sel_r <= data_cache_sel_r;

			if(data_cache_clr)
				data_cache_ready <= 0;
			else if(data_cache_sel_r ^ data_cache_cnt[1])
				data_cache_ready <= 1;
			else
				data_cache_ready <= data_cache_ready;
			// case({data_cache_clr, tcd1304_fifo_valid})
			// 	2'b00 : data_cache_ready <= data_cache_ready;
			// 	2'b01 : data_cache_ready <= (data_cache_sel_r ^ data_cache_cnt[1]);
			// 	2'b10 : data_cache_ready <= 0;
			// 	2'b11 : data_cache_ready <= (data_cache_sel_r ^ data_cache_cnt[1]);
			// endcase // {data_cache_clr, tcd1304_fifo_valid}
		end

	// sel region
	always @ (posedge clk)
		if(!rst_n)
			region_sel_r <= 0;
		else
			if({mst_state, tcd1304_frame_start[0]}=={IDLE, 1'b1})
				region_sel_r <= ~region_sel_r;
			else
				region_sel_r <= region_sel_r;


	// write to fifo
	always @ (posedge clk)
		if(!rst_n) begin
			wrfifo_data <= 0;
			wrfifo_wren <= 0;
			internal_cnt2 <= 0;
			data_cache_clr <= 0;
		end
		else 
			case(mst_state)
				WR2FIFO : begin
					if(data_cache_ready) begin
						case(internal_cnt2)
							4'd0 : wrfifo_data <= (data_cache_sel_r==1'b1)?data_cache1[63:0]:data_cache2[63:0];
							4'd1 : wrfifo_data <= (data_cache_sel_r==1'b1)?data_cache1[127:64]:data_cache2[127:64];
							4'd2 : wrfifo_data <= (data_cache_sel_r==1'b1)?data_cache1[191:128]:data_cache2[191:128];
							4'd3 : wrfifo_data <= (data_cache_sel_r==1'b1)?data_cache1[255:192]:data_cache2[255:192];
							4'd4 : wrfifo_data <= (data_cache_sel_r==1'b1)?data_cache1[319:256]:data_cache2[319:256];
							default : wrfifo_data <= wrfifo_data;
						endcase
						wrfifo_wren <= 1;
						if(internal_cnt2==4'd4)
							internal_cnt2 <= 0;
						else
							internal_cnt2 <= internal_cnt2 + 1'b1;
						if(internal_cnt2==4'd3)
							data_cache_clr <= 1;
						else
							data_cache_clr <= 0;
					end
					else begin
						wrfifo_data <= wrfifo_data;
						wrfifo_wren <= 0;
						internal_cnt2 <= 0;
						data_cache_clr <= 0;
					end
				end
				FILLFIFO : begin
					wrfifo_data <= 0;
					wrfifo_wren <= 1;
				end
				default : begin
					wrfifo_data <= 0;
					wrfifo_wren <= 0;
					internal_cnt2 <= 0;
					data_cache_clr <= 0;
				end
			endcase

	// region logic
	always @ (posedge clk)
		if(!rst_n) begin
			region_indc_r <= 0;
			region_valid_r <= 0;
			region_indc_int <= 0;
		end
		else begin
			case(mst_state)
				IDLE : begin
					if(tcd1304_frame_start[0]) begin
						region_indc_int <= ~region_indc_int;
						region_indc_r <= ~region_indc_int;
						region_valid_r <= 1;
					end
					else begin
						region_indc_int <= region_indc_int;
						region_indc_r <= region_indc_r;
						region_valid_r <= 0;
					end
				end

				default : begin
					region_indc_r <= region_indc_r;
					region_valid_r <= 0;
					region_indc_int <= region_indc_int;
				end
			endcase
		end


	// internal count
	always @ (posedge clk)
		if(!rst_n)
			internal_cnt <= 0;
		else begin
			case (mst_state)
				WR2FIFO : 
					if(wrfifo_wren)
						if(internal_cnt>=DATA_LEN-1)
							internal_cnt <= 0;
						else
							internal_cnt <= internal_cnt + 1'b1;
					else
						internal_cnt <= internal_cnt;

				FILLFIFO : 
					if(internal_cnt>=16)
						internal_cnt <= 0;
					else
						internal_cnt <= internal_cnt + 1'b1;

				default : internal_cnt <= 0;
			endcase
		end



	// main state machine
	always @ (posedge clk)
		if(!rst_n) 
			mst_state <= IDLE;
		else
			case (mst_state)
				IDLE : 
					if(tcd1304_frame_start[0])
						mst_state <= WR2FIFO;
					else
						mst_state <= IDLE;

				WR2FIFO : 
					if(internal_cnt>=DATA_LEN-1)
						mst_state <= FILLFIFO;
					else
						mst_state <= WR2FIFO;

				FILLFIFO : 
					if(internal_cnt>=16)
						mst_state <= WRDONE;
					else
						mst_state <= FILLFIFO;

				WRDONE : 
					mst_state <= IDLE;
			endcase

	// output logic
	always @ (posedge clk)
		if(!rst_n) begin
			fifo_1_wdata_r <= 0;
			fifo_1_wren_r <= 0;
			fifo_2_wdata_r <= 0;
			fifo_2_wren_r <= 0;
		end
		else begin
			if(region_indc_int==1'b1) begin
				fifo_1_wdata_r <= wrfifo_data;
				fifo_1_wren_r <= wrfifo_wren;
			end
			else begin
				fifo_2_wdata_r <= wrfifo_data;
				fifo_2_wren_r <= wrfifo_wren;
			end
		end

	assign fifo_1_wdata = fifo_1_wdata_r;
	assign fifo_1_wren = fifo_1_wren_r;
	assign fifo_2_wdata = fifo_2_wdata_r;
	assign fifo_2_wren = fifo_2_wren_r;
	assign region_indc = region_indc_r;
	assign region_valid = region_valid_r;
	assign init_txn = tcd1304_frame_start[0];

endmodule