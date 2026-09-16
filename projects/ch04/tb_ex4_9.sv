`timescale 1ns/1ps

module tb_ex4_9;
    logic		a;
    logic		b;
    logic		c;
	logic		y;

    ex4_9 dut (
		.a	(a),
		.b	(b),
		.c	(c),
		.y	(y)
	);

	initial begin
    	$dumpfile("build/ex4_9.vcd");
    	$dumpvars(0, tb_ex4_9);
		a = 0; b = 0; c = 0;
		#1;
		assert (y == 1'b1) else $error(1, "a=%d b=%d c=%d y=%d", a, b, c, y);
		a = 0; b = 0; c = 1;
		#1;
		assert (y == 1'b0) else $error(1, "a=%d b=%d c=%d y=%d", a, b, c, y);
		a = 0; b = 1; c = 0;
		#1;
		assert (y == 1'b0) else $error(1, "a=%d b=%d c=%d y=%d", a, b, c, y);
		a = 1; b = 0; c = 0;
		#1;
		assert (y == 1'b1) else $error(1, "a=%d b=%d c=%d y=%d", a, b, c, y);
		a = 1; b = 1; c = 0;
		#1;
		assert (y == 1'b0) else $error(1, "a=%d b=%d c=%d y=%d", a, b, c, y);
		a = 1; b = 1; c = 1;
		#1;
		assert (y == 1'b0) else $error(1, "a=%d b=%d c=%d y=%d", a, b, c, y);
		$display("PASS: ex4_9 behavior");
		$finish;
	end
endmodule

