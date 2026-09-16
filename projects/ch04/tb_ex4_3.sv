`timescale 1ns/1ps

module tb_ex4_3;
    logic [3:0] a;
	logic		y;

    ex4_3 dut (
		.a	(a),
		.y	(y)
	);

	initial begin
    	$dumpfile("build/ex4_3.vcd");
    	$dumpvars(0, tb_ex4_3);
		a = 4'b1100;
		#1;
		assert (y == 1'b0) else $fatal(1, "a=%04b y=%d", a, y);
		a = 4'b1001;
		#1;
		assert (y == 1'b0) else $fatal(1, "a=%04b y=%d", a, y);
		a = 4'b0001;
		#1;
		assert (y == 1'b1) else $fatal(1, "a=%04b y=%d", a, y);
		a = 4'b1000;
		#1;
		assert (y == 1'b1) else $fatal(1, "a=%04b y=%d", a, y);
		$display("PASS: ex4_3 behavior");
		$finish;
	end
endmodule
