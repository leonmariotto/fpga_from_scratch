`timescale 1ns/1ps

module tb_ex4_13;
    logic	[1:0]	in;
    logic	[3:0]	out;

    ex4_13 dut (
		.in		(in),
		.out	(out)
	);

	initial begin
    	$dumpfile("build/ex4_13.vcd");
    	$dumpvars(0, tb_ex4_13);
		in = 2'd0;
		#1;
		assert (out == 4'b0001) else $error(1, "in=%d out=%04b", in, out);
		in = 2'd1;
		#1;
		assert (out == 4'b0010) else $error(1, "in=%d out=%04b", in, out);
		in = 2'd2;
		#1;
		assert (out == 4'b0100) else $error(1, "in=%d out=%04b", in, out);
		in = 2'd3;
		#1;
		assert (out == 4'b1000) else $error(1, "in=%d out=%04b", in, out);
		$display("PASS: ex4_13 behavior");
		$finish;
	end
endmodule


