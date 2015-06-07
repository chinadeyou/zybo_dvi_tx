// ---------------------------------------------------------------------------
//
//                                      Copyright (C) 2015 by Ryuji Fuchikami
//                                      http://homepage3.nifty.com/ryuz
// ---------------------------------------------------------------------------


`timescale 1ns / 1ps
`default_nettype none


module tb_top();
	
	initial begin
		$dumpfile("tb_top.vcd");
		$dumpvars(2, tb_top);
		$dumpvars(0, tb_top.i_top.i_vsync_generator);
	
	#1000000
		$finish;
	end

	
	top
		i_top
			(
				.led	()
			);
	
endmodule


`default_nettype wire


// end of file
