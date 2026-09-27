module tb_register;
	logic clk = 0;
	logic reset;
	logic [31:0] d, q;

	register dut (.*);
	always #5 clk = ~clk;

	task automatic tick;
		@(posedge clk); #1;
	endtask

	initial begin
		reset = 1; d = 32'hdead_beef;
		tick();
		assert (q === 0) else $fatal(1, "Register did not reset");

		reset = 0; d = 32'h1234_5678;
		tick();
		assert (q === d) else $fatal(1, "Register did not capture d");

		d = 32'hffff_0000;
		#2;
		assert (q === 32'h1234_5678) else $fatal(1, "Register changed off-edge");
		tick();
		assert (q === d) else $fatal(1, "Second capture failed");

		$display("PASS: tb_register");
		$finish;
	end
endmodule
