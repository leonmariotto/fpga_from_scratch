`timescale 1ns/1ps

module tb_register;
	logic clk = 1'b0;
	logic [3:0] d;
	logic [3:0] q;
	logic [3:0] next;

	register dut (
		.clk (clk),
		.d (d),
		.q (q)
	);

	// Instruct the simulator to inverse clk signal every 5ns, a complete
	// period is 10ns.
	always #5 clk = ~clk;

	initial begin
    	$dumpfile("build/register.vcd");
    	$dumpvars(0, tb_register);

		for (int i = 0; i < 15; i++) begin

			d = i[3:0];

			// Wait for a rising clock edge
			@(posedge clk);
			#1;

			assert(q === i[3:0])
				else $fatal(1, "q=%04b expected=%04b", q, i);

			next = i + 1;
			d = next;

			// q should not change before the next rising edge
			#2;
			assert(q === i[3:0])
				else $fatal(1, "q=%04b expected=%04b", q, i);

			@(posedge clk);
			#1;
			assert(q === next[3:0])
				else $fatal(1, "q=%04b expected=%04b", q, next);

			$display("PASS: register behavior");
		end
		#10;
		$finish;
	end
endmodule
