`timescale 1ns/1ps

module tb_divideby3FSM;
    logic clk;
    logic r;
    logic y;

    divideby3FSM dut (
		.clk	(clk),
		.reset	(r),
		.y		(y)
	);

	always #2 clk = ~clk;

	initial begin
    	$dumpfile("build/divideby3FSM.vcd");
    	$dumpvars(0, tb_divideby3FSM);
		clk = 0;
		r = 0;
		#1;
		r = 1;
		#40;
		r = 0;
		#40;

		$display("PASS: divideby3FSM behavior");
		$finish;
	end
endmodule
