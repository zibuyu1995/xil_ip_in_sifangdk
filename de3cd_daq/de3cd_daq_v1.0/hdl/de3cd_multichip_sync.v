// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : hao liang (Ash) a529481713@gmail.com
// File   : de3cd_multichip_sync.v
// Create : 2020-04-20 15:12:13
// Revised: 2020-04-20 16:08:02
// Editor : sublime text3, tab size (4)
// Coding : UTF-8
// -----------------------------------------------------------------------------
module de3cd_multichip_sync (
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low
	//
	input clk_2m,
	input tcd1304_sh,
	input [1:0] sync_phase,
	input tcd1304_load,
	//
	output ads8556_syncn
);

	reg tcd1304_sh_q = 0;
	reg clk_2m_q = 0;
	reg [1:0] phase_val;
	reg [1:0] phase_cnt;
	reg update_protect_flag;
	reg phase_update_flag;
	reg ads8556_syncn_r;

	wire tcd1304_sh_rise;
	wire tcd1304_sh_fall;
	wire clk_2m_rise;

	// sh
	always @ (posedge clk) begin
		tcd1304_sh_q <= tcd1304_sh;
	end

	assign tcd1304_sh_rise = ({tcd1304_sh_q, tcd1304_sh}==2'b01);
	assign tcd1304_sh_fall = ({tcd1304_sh_q, tcd1304_sh}==2'b10);

	// clk
	always @ (posedge clk) begin
		clk_2m_q <= clk_2m;
	end

	assign clk_2m_rise = ({clk_2m_q, clk_2m}==2'b01);

	// phase val load
	always @ (posedge clk)
		if(!rst_n)
			phase_val <= 0;
		else if(tcd1304_load)	
			phase_val <= sync_phase;
		else
			phase_val <= phase_val;

	// update protect flag
	// if tcd1304_load at sh assert, will be update phase at next sh pulse.
	always @ (posedge clk)
		if(!rst_n||tcd1304_load)
			update_protect_flag <= 0;
		else if(tcd1304_sh_rise)
			update_protect_flag <= 1;
		else if(tcd1304_sh_fall)
			update_protect_flag <= 0;
		else
			update_protect_flag <= update_protect_flag;

	// phase update flag
	always @ (posedge clk)
		if(!rst_n||tcd1304_load)
			phase_update_flag <= 1;
		else if(tcd1304_sh_fall&&update_protect_flag)
			phase_update_flag <= 0;
		else
			phase_update_flag <= phase_update_flag;

	// phase cnt
	always @ (posedge clk)
		if(!rst_n||phase_update_flag)
			phase_cnt <= 0;
		else if(clk_2m_rise)
			if(phase_cnt==phase_val)
				phase_cnt <= phase_cnt;
			else
				phase_cnt <= phase_cnt + 1'b1;
		else
			phase_cnt <= phase_cnt;

	// sync output
	always @ (posedge clk)
		if(!rst_n||(phase_update_flag&&tcd1304_sh_rise))
			ads8556_syncn_r <= 1;
		else if((phase_cnt==phase_val)&&(phase_update_flag==1'b0))
			ads8556_syncn_r <= 0;
		else
			ads8556_syncn_r <= ads8556_syncn_r;

	// output logic
	assign ads8556_syncn = ads8556_syncn_r;

endmodule