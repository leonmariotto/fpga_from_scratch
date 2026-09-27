module tb_regfile;
	logic clk = 0;
	logic we3;
	logic [5:0] a1, a2, a3;
	logic [31:0] wd3, rd1, rd2;

	regfile dut (.*);
	always #5 clk = ~clk;

	task automatic tick;
		@(posedge clk); #1;
	endtask

	initial begin
		we3 = 0; a1 = 0; a2 = 0; a3 = 0; wd3 = 0; #1;
		assert (rd1 === 0 && rd2 === 0) else $fatal(1, "x0 did not read as zero");

		we3 = 1; a3 = 6'd5; wd3 = 32'h1234_5678;
		tick();
		a1 = 6'd5; #1;
		assert (rd1 === wd3) else $fatal(1, "Write/read of x5 failed");

		we3 = 1; a3 = 6'd9; wd3 = 32'hdead_beef;
		tick();
		a2 = 6'd9; #1;
		assert (rd1 === 32'h1234_5678 && rd2 === 32'hdead_beef)
			else $fatal(1, "Independent read ports failed");

		we3 = 0; a3 = 6'd5; wd3 = 32'hffff_ffff;
		tick();
		assert (rd1 === 32'h1234_5678) else $fatal(1, "Write enable was ignored");

		we3 = 1; a3 = 0; wd3 = 32'hffff_ffff;
		tick();
		a1 = 0; #1;
		assert (rd1 === 0) else $fatal(1, "x0 was not hardwired to zero");

		$display("PASS: tb_regfile");
		$finish;
	end
endmodule
