// Generated by FFT 2.1.3 [Altera, IP Toolbench v1.2.7 build38]
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
// ************************************************************
// Copyright (C) 1991-2005 Altera Corporation
// Any megafunction design, and related net list (encrypted or decrypted),
// support information, device programming or simulation file, and any other
// associated documentation or information provided by Altera or a partner
// under Altera's Megafunction Partnership Program may be used only to
// program PLD devices (but not masked PLD devices) from Altera.  Any other
// use of such megafunction design, net list, support information, device
// programming or simulation file, or any other related documentation or
// information is prohibited for any other purpose, including, but not
// limited to modification, reverse engineering, de-compiling, or use with
// any other silicon devices, unless such use is explicitly licensed under
// a separate agreement with Altera or a megafunction partner.  Title to
// the intellectual property, including patents, copyrights, trademarks,
// trade secrets, or maskworks, embodied in any such megafunction design,
// net list, support information, device programming or simulation file, or
// any other related documentation or information provided by Altera or a
// megafunction partner, remains with Altera, the megafunction partner, or
// their respective licensors.  No other licenses, including any licenses
// needed under any third party's intellectual property, are provided herein.

module fft_small (
	clk,
	reset,
	master_sink_dav,
	master_sink_sop,
	master_source_dav,
	inv_i,
	data_real_in,
	data_imag_in,
	fft_real_out,
	fft_imag_out,
	exponent_out,
	master_sink_ena,
	master_source_sop,
	master_source_eop,
	master_source_ena);

	input		clk;
	input		reset;
	input		master_sink_dav;
	input		master_sink_sop;
	input		master_source_dav;
	input		inv_i;
	input	[15:0]	data_real_in;
	input	[15:0]	data_imag_in;
	output	[15:0]	fft_real_out;
	output	[15:0]	fft_imag_out;
	output	[5:0]	exponent_out;
	output		master_sink_ena;
	output		master_source_sop;
	output		master_source_eop;
	output		master_source_ena;
endmodule
