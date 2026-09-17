`timescale 1ns/1ps

module tb_ex4_29;
    logic clk;
    logic r;
	logic ta;
	logic tb;
	logic [1:0] la;
	logic [1:0] lb;
	typedef enum logic [1:0] {GREEN, YELLOW, RED} outputtype;

	ex4_29 dut (
		.clk	(clk),
		.reset	(r),
		.ta		(ta),
		.tb		(tb),
		.la		(la),
		.lb		(lb)
	);

	always #1 clk = ~clk;

	initial begin
    	$dumpfile("build/ex4_29.vcd");
    	$dumpvars(0, tb_ex4_29);

		// No trafic
		ta = 0;
		tb = 0;

		// Init clock and reset
		clk = 0;
		r = 1;
    	@(posedge clk);
		#1;
		r = 0;

    	@(posedge clk);
		#1;
		assert (la === YELLOW) else $fatal(1, "err");
		assert (lb === RED) else $fatal(1, "err");

    	@(posedge clk);
		#1;
		assert (la === RED) else $fatal(1, "err");
		assert (lb === GREEN) else $fatal(1, "err");

    	@(posedge clk);
		#1;
		assert (la === RED) else $fatal(1, "err");
		assert (lb === YELLOW) else $fatal(1, "err");

		ta = 1;

    	@(posedge clk);
		#1;
		assert (la === GREEN) else $fatal(1, "err");
		assert (lb === RED) else $fatal(1, "err");
    	@(posedge clk);
		#1;
		assert (la == GREEN) else $fatal(1, "err");
		assert (lb == RED) else $fatal(1, "err");
    	@(posedge clk);
		#1;
		assert (la == GREEN) else $fatal(1, "err");
		assert (lb == RED) else $fatal(1, "err");

		tb = 1;
		ta = 0;
    	@(posedge clk);
		#1;
		assert (la == YELLOW) else $fatal(1, "err");
		assert (lb == RED) else $fatal(1, "err");

    	@(posedge clk);
		#1;
		assert (la == RED) else $fatal(1, "err");
		assert (lb == GREEN) else $fatal(1, "err");
		
    	@(posedge clk);
		#1;
		assert (la == RED) else $fatal(1, "err");
		assert (lb == GREEN) else $fatal(1, "err");



		$display("PASS: ex4_29 behavior");
		$finish;
	end
endmodule

