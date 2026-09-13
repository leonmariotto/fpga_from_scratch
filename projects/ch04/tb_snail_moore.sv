`timescale 1ns/1ps


module tb_snail_moore;
    logic clk;
    logic r;
    logic a;
    logic y_moore;

    snail_moore dut (
		.clk	(clk),
		.reset	(r),
		.a		(a),
		.y		(y_moore)
	);

	logic [1:0] sim [0:3] = '{
    	2'b10,
    	2'b00,
    	2'b11,
    	2'b10
  	};

	always #4 clk = ~clk;

	initial begin
    	$dumpfile("build/snail_moore.vcd");
    	$dumpvars(0, tb_snail_moore);
		// Init the clock
		clk = 0;

		// Reset
		r = 1;
    	@(posedge clk);
		#1;
		r = 0;

		foreach (sim[i]) begin
    	    @(negedge clk);
    	    a = sim[i][1];
			// Check the output after the rising edges. Because output depends
			// only on state, we need to wait for state to settle, and check
			// the next output. Wait for edges before output check.
    	    @(posedge clk);
    	    #1;

    	    assert (y_moore === sim[i][0])
    	        else $fatal(
					1,
    	            "Moore: step=%0d a=%b expected=%b actual=%b",
    	            i, a, sim[i][0], y_moore
    	        );
    	end

		$display("PASS: snail_moore behavior");
		$finish;
	end
endmodule


