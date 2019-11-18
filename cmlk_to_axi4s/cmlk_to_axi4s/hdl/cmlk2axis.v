// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : cmlk2axis.v
// Create : 2019-09-24 10:20:37
// Revised: 2019-11-07 10:52:05
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cmlk2axis(
		input clk,
		input rst_n,
		// cameralink interface 
		input [27:0] cmlk_data_x,
		input [27:0] cmlk_data_y,
		input [27:0] cmlk_data_z,
		input cmlk_data_valid,
		// axi stream interface
		output [63:0] m_axis_cmlk_tdata,
		output m_axis_cmlk_tlast,
		input m_axis_cmlk_tready,
		output m_axis_cmlk_tuser,
		output m_axis_cmlk_tvalid,
		// misc
		output fstart_err,
		output lval_err,
		output overflow
	);

	localparam FIFO_RD_IDLE = 2'b00;
	localparam FIFO_RD_CACHE = 2'b01;
	localparam FIFO_RD_DONE = 2'b10;

	wire [7:0] cmlk_port_a;
	wire [7:0] cmlk_port_b;
	wire [7:0] cmlk_port_c;
	wire [7:0] cmlk_port_d;
	wire [7:0] cmlk_port_e;
	wire [7:0] cmlk_port_f;
	wire [7:0] cmlk_port_g;
	wire [7:0] cmlk_port_h;

	wire cmlk_x_lval;
	wire cmlk_x_fval;
	wire cmlk_x_dval;
	wire cmlk_y_lval;
	wire cmlk_y_fval;
	wire cmlk_y_dval;
	wire cmlk_z_lval;
	wire cmlk_z_fval;
	wire cmlk_z_dval;

	reg [1:0] cmlk_x_fval_q;
	reg [1:0] cmlk_y_fval_q;
	reg [1:0] cmlk_z_fval_q;
	wire cmlk_x_fval_posedge;
	wire cmlk_y_fval_posedge;
	wire cmlk_z_fval_posedge;

	wire fifo_x_rst;
	wire fifo_y_rst;
	wire fifo_z_rst;

	(* MARK_DEBUG="true" *)reg fifo_x_wren;
	(* MARK_DEBUG="true" *)reg fifo_y_wren;
	(* MARK_DEBUG="true" *)reg fifo_z_wren;
	(* MARK_DEBUG="true" *)reg [31:0] fifo_x_wrdata;
	(* MARK_DEBUG="true" *)reg [31:0] fifo_y_wrdata;
	(* MARK_DEBUG="true" *)reg [31:0] fifo_z_wrdata;
	reg frame_start_x;
	reg frame_start_y;
	reg frame_start_z;

	reg [7:0] lval_cnt;
	wire line_end;

	wire fifo_x_wrfull;
	wire fifo_y_wrfull;
	wire fifo_z_wrfull;

	wire fifo_rden;

	wire [31:0] fifo_x_rddata;
	wire [31:0] fifo_y_rddata;
	wire [31:0] fifo_z_rddata;

	wire fifo_x_rdempty;
	wire fifo_y_rdempty;
	wire fifo_z_rdempty;

	// integer i;
	// reg [1:0] fifo_rd_state;
	// reg [2:0] data_cache_cnt;
	// reg cache_sel;
	// reg [63:0] data_cache0[7:0];
	// reg [63:0] data_cache1[7:0];
	// reg data_cache_ready_0;
	// reg data_cache_ready_1;
	// wire data_cache_ready;
	// reg data_cache_indc; // 0---cache 0, 1---cache 1
	// reg data_cache_clr;
	// reg cache_collision_r;

	reg overflow_x;
	reg overflow_y;
	reg overflow_z;
	reg overflow_r;

	reg lval_err_r;
	reg fstart_err_r;

	// cameralink full signal reassign
	assign cmlk_x_lval = cmlk_data_x[24];
	assign cmlk_x_fval = cmlk_data_x[25];
	assign cmlk_x_dval = cmlk_data_x[26];

	assign cmlk_y_lval = cmlk_data_y[24];
	assign cmlk_y_fval = cmlk_data_y[25];
	assign cmlk_y_dval = cmlk_data_y[26];
	
	assign cmlk_z_lval = cmlk_data_z[24];
	assign cmlk_z_fval = cmlk_data_z[25];
	assign cmlk_z_dval = cmlk_data_z[26];

	assign cmlk_port_a = {cmlk_data_x[5], cmlk_data_x[27], cmlk_data_x[6], cmlk_data_x[4:0]};
	assign cmlk_port_b = {cmlk_data_x[11:10], cmlk_data_x[14:12], cmlk_data_x[9:7]};
	assign cmlk_port_c = {cmlk_data_x[17:16], cmlk_data_x[22:18], cmlk_data_x[15]};

	assign cmlk_port_d = {cmlk_data_y[5], cmlk_data_y[27], cmlk_data_y[6], cmlk_data_y[4:0]};
	assign cmlk_port_e = {cmlk_data_y[11:10], cmlk_data_y[14:12], cmlk_data_y[9:7]};
	assign cmlk_port_f = {cmlk_data_y[17:16], cmlk_data_y[22:18], cmlk_data_y[15]};

	assign cmlk_port_g = {cmlk_data_z[5], cmlk_data_z[27], cmlk_data_z[6], cmlk_data_z[4:0]};
	assign cmlk_port_h = {cmlk_data_z[11:10], cmlk_data_z[14:12], cmlk_data_z[9:7]};

	// detect frame start
	always @ (posedge clk)
		if(!rst_n) begin
			cmlk_x_fval_q <= 0;
			cmlk_y_fval_q <= 0;
			cmlk_z_fval_q <= 0;
		end
		else if(cmlk_data_valid) begin
			cmlk_x_fval_q <= {cmlk_x_fval_q[0], cmlk_x_fval};
			cmlk_y_fval_q <= {cmlk_y_fval_q[0], cmlk_y_fval};
			cmlk_z_fval_q <= {cmlk_z_fval_q[0], cmlk_z_fval};
		end
		else begin
			cmlk_x_fval_q <= cmlk_x_fval_q;
			cmlk_y_fval_q <= cmlk_y_fval_q;
			cmlk_z_fval_q <= cmlk_z_fval_q;
		end

	assign cmlk_x_fval_posedge = (cmlk_x_fval_q==2'b01);
	assign cmlk_y_fval_posedge = (cmlk_y_fval_q==2'b01);
	assign cmlk_z_fval_posedge = (cmlk_z_fval_q==2'b01);

	// detect line end
	always @ (posedge clk)
		if(!rst_n|cmlk_x_fval_posedge)
			lval_cnt <= 0;
		// else if({cmlk_x_lval, cmlk_x_dval}==2'b11)
		else if({cmlk_x_lval, cmlk_data_valid}==2'b11)
			lval_cnt <= lval_cnt + 1;
		else
			lval_cnt <= lval_cnt;

	assign line_end = (lval_cnt==255);

	// generate fifo write
	assign fifo_x_rst = cmlk_x_fval_posedge;
	assign fifo_y_rst = cmlk_x_fval_posedge;//cmlk_y_fval_posedge;
	assign fifo_z_rst = cmlk_x_fval_posedge;//cmlk_z_fval_posedge;

	always @ (posedge clk)
		if(!rst_n) begin
			frame_start_x <= 0;
			frame_start_y <= 0;
			frame_start_z <= 0;
		end
		else if(cmlk_data_valid) begin
			if(cmlk_x_fval_posedge)
				frame_start_x <= 1;
			// else if({cmlk_x_lval, cmlk_x_dval}==2'b11)
			else if(cmlk_x_lval==1'b1)
				frame_start_x <= 0;
			else
				frame_start_x <= frame_start_x;

			if(cmlk_y_fval_posedge)
				frame_start_y <= 1;
			// else if({cmlk_y_lval, cmlk_y_dval}==2'b11)
			else if(cmlk_y_lval==1'b1)
				frame_start_y <= 0;
			else
				frame_start_y <= frame_start_y;

			if(cmlk_z_fval_posedge)
				frame_start_z <= 1;
			// else if({cmlk_z_lval, cmlk_z_dval}==2'b11)
			else if(cmlk_z_lval==1'b1)
				frame_start_z <= 0;
			else
				frame_start_z <= frame_start_z;
		end
		else begin
			frame_start_x <= frame_start_x;
			frame_start_y <= frame_start_y;
			frame_start_z <= frame_start_z;
		end

	always @ (posedge clk)
		if(!rst_n) begin
			fifo_x_wren <= 0;
			fifo_y_wren <= 0;
			fifo_z_wren <= 0;
			fifo_x_wrdata <= 0;
			fifo_y_wrdata <= 0;
			fifo_z_wrdata <= 0;
		end
		else if(cmlk_data_valid) begin
			// fifo_x_wren <= ({cmlk_x_lval, cmlk_x_dval}==2'b11);
			// fifo_y_wren <= ({cmlk_y_lval, cmlk_y_dval}==2'b11);
			// fifo_z_wren <= ({cmlk_z_lval, cmlk_z_dval}==2'b11);
			fifo_x_wren <= (cmlk_x_lval==1'b1);
			fifo_y_wren <= (cmlk_y_lval==1'b1);
			fifo_z_wren <= (cmlk_z_lval==1'b1);
			fifo_x_wrdata <= {6'd0, line_end, frame_start_x, cmlk_port_c, cmlk_port_b, cmlk_port_a};
			fifo_y_wrdata <= {7'd0, frame_start_y, cmlk_port_f, cmlk_port_e, cmlk_port_d};
			fifo_z_wrdata <= {7'd0, frame_start_z, 8'd0, cmlk_port_h, cmlk_port_g};
		end
		else begin
			fifo_x_wren <= 0;
			fifo_y_wren <= 0;
			fifo_z_wren <= 0;
			fifo_x_wrdata <= fifo_x_wrdata;
			fifo_y_wrdata <= fifo_y_wrdata;
			fifo_z_wrdata <= fifo_z_wrdata;
		end

	// fifo inst
	asfifo_18k asfifo_18k_x_i0(
		.wr_clk (clk),
		.rd_clk (clk),
		.rst    (fifo_x_rst),
		.full   (fifo_x_wrfull),
		.din    (fifo_x_wrdata),
		.wr_en  (fifo_x_wren),
		.empty  (fifo_x_rdempty),
		.dout   (fifo_x_rddata),
		.rd_en  (fifo_rden)
	);

	asfifo_18k asfifo_18k_y_i0(
		.wr_clk (clk),
		.rd_clk (clk),
		.rst    (fifo_y_rst),
		.full   (fifo_y_wrfull),
		.din    (fifo_y_wrdata),
		.wr_en  (fifo_y_wren),
		.empty  (fifo_y_rdempty),
		.dout   (fifo_y_rddata),
		.rd_en  (fifo_rden)
	);

	asfifo_18k asfifo_18k_z_i0(
		.wr_clk (clk),
		.rd_clk (clk),
		.rst    (fifo_z_rst),
		.full   (fifo_z_wrfull),
		.din    (fifo_z_wrdata),
		.wr_en  (fifo_z_wren),
		.empty  (fifo_z_rdempty),
		.dout   (fifo_z_rddata),
		.rd_en  (fifo_rden)
	);

	// fifo read proc
	assign fifo_rden = m_axis_cmlk_tready && m_axis_cmlk_tvalid;
	assign m_axis_cmlk_tvalid = ({fifo_z_rdempty, fifo_y_rdempty, fifo_x_rdempty}==3'b000);
	assign m_axis_cmlk_tuser = fifo_x_rddata[24];
	assign m_axis_cmlk_tdata = {fifo_z_rddata[15:0], fifo_y_rddata[23:0], fifo_x_rddata[23:0]};
	assign m_axis_cmlk_tlast = fifo_x_rddata[25];

	// always @ (posedge clk)
	// 	if(!rst_n) 
	// 		fifo_rd_state <= FIFO_RD_IDLE;
	// 	else
	// 		case (fifo_rd_state)
	// 			FIFO_RD_IDLE : 
	// 				if({data_cache_ready_0, data_cache_ready_1}==2'b11)
	// 					fifo_rd_state <= FIFO_RD_IDLE;
	// 				else
	// 					fifo_rd_state <= FIFO_RD_CACHE;
	// 			FIFO_RD_CACHE : 
	// 				if((data_cache_cnt==3'd7)&&(fifo_rden==1'b1))
	// 					fifo_rd_state <= FIFO_RD_DONE;
	// 				else
	// 					fifo_rd_state <= FIFO_RD_CACHE;
	// 			FIFO_RD_DONE : 
	// 				fifo_rd_state <= FIFO_RD_IDLE;
	// 			default : fifo_rd_state <= FIFO_RD_IDLE;
	// 		endcase

	// assign fifo_rden = ({fifo_rd_state, fifo_z_rdempty, fifo_y_rdempty, fifo_x_rdempty}=={FIFO_RD_CACHE, 3'b000});

	// always @ (posedge clk)
	// 	if(!rst_n) begin
	// 		data_cache_cnt <= 0;
	// 		cache_sel <= 0;
	// 		for(i=0; i<8; i=i+1) begin
	// 			data_cache0[i] <= 0;
	// 			data_cache1[i] <= 0;
	// 		end
	// 	end
	// 	else begin
	// 		if(fifo_rden) 
	// 			data_cache_cnt <= data_cache_cnt + 1'b1;
	// 		else
	// 			data_cache_cnt <= data_cache_cnt;
	// 		if(fifo_rden) begin
	// 			if(cache_sel==1'b0)
	// 				data_cache0[data_cache_cnt] <= {fifo_z_rddata[15:0], fifo_y_rddata[23:0], fifo_x_rddata[23:0]};
	// 			else
	// 				data_cache1[data_cache_cnt] <= {fifo_z_rddata[15:0], fifo_y_rddata[23:0], fifo_x_rddata[23:0]};
	// 		end
	// 		if(fifo_rd_state==FIFO_RD_DONE)
	// 			cache_sel <= ~cache_sel;
	// 		else
	// 			cache_sel <= cache_sel;
	// 	end

	// always @ (posedge clk)
	// 	if(!rst_n) begin
	// 		data_cache_ready_0 <= 0;
	// 		data_cache_ready_1 <= 0;
	// 		data_cache_indc <= 0;
	// 		cache_collision_r <= 0;
	// 	end
	// 	else 
	// 		case(fifo_rd_state)
	// 			FIFO_RD_DONE : begin
	// 				if(data_cache_clr) begin
	// 					if({data_cache_indc, cache_sel}==2'b01) begin
	// 						data_cache_ready_0 <= 0;
	// 						data_cache_ready_1 <= 1;
	// 					end
	// 					else if({data_cache_indc, cache_sel}==2'b10) begin
	// 						data_cache_ready_0 <= 1;
	// 						data_cache_ready_1 <= 0;
	// 					end
	// 					else begin
	// 						cache_collision_r <= 1;
	// 						data_cache_ready_0 <= data_cache_ready_0;
	// 						data_cache_ready_1 <= data_cache_ready_1;
	// 					end
	// 					data_cache_indc <= ~data_cache_indc;
	// 				end
	// 				else begin
	// 					if(cache_sel==1'b0) begin
	// 						data_cache_ready_0 <= 1;
	// 						data_cache_ready_1 <= data_cache_ready_1;
	// 					end
	// 					else begin
	// 						data_cache_ready_0 <= data_cache_ready_0;
	// 						data_cache_ready_1 <= 1;
	// 					end
	// 					data_cache_indc <= data_cache_indc;
	// 				end
	// 			end
	// 			default : begin
	// 				cache_collision_r <= cache_collision_r;
	// 				if(data_cache_clr) begin
	// 					if(data_cache_indc==1'b0) begin
	// 						data_cache_ready_0 <= 0;
	// 						data_cache_ready_1 <= data_cache_ready_1;
	// 					end
	// 					else begin
	// 						data_cache_ready_0 <= data_cache_ready_0;
	// 						data_cache_ready_1 <= 0;
	// 					end
	// 					data_cache_indc <= ~data_cache_indc;
	// 				end
	// 				else begin
	// 					data_cache_ready_0 <= data_cache_ready_0;
	// 					data_cache_ready_1 <= data_cache_ready_1;
	// 					data_cache_indc <= data_cache_indc;
	// 				end
	// 			end
	// 		endcase // fifo_rd_state

	// assign data_cache_ready = data_cache_ready_0 | data_cache_ready_1;

	// misc proc
	always @ (posedge clk)
		if(!rst_n) begin
			overflow_x <= 0;
			overflow_y <= 0;
			overflow_z <= 0;
			overflow_r <= 0;
		end
		else begin
			overflow_x <= ({fifo_x_wrfull, fifo_x_wren}==2'b11)?1'b1:overflow_x;
			overflow_y <= ({fifo_y_wrfull, fifo_y_wren}==2'b11)?1'b1:overflow_y;
			overflow_z <= ({fifo_z_wrfull, fifo_z_wren}==2'b11)?1'b1:overflow_z;
			if(overflow_x==1'b1||overflow_y==1'b1||overflow_z==1'b1)
				overflow_r <= 1'b1;
			else
				overflow_r <= overflow_r;
		end

	always @ (posedge clk)
		if(!rst_n)
			fstart_err_r <= 0;
		else
			fstart_err_r <= fstart_err_r;

	assign fstart_err = fstart_err_r;
	assign lval_err = 1'b0;
	assign overflow = overflow_r;


endmodule
