`timescale 1ns/1ps


module tb_snail_mealy;
    logic clk;
    logic r;
    logic a;
    logic y_mealy;

    snail_mealy dut (
		.clk	(clk),
		.reset	(r),
		.a		(a),
		.y		(y_mealy)
	);

	logic [1:0] sim [0:3] = '{
    	2'b10,
    	2'b00,
    	2'b11,
    	2'b10
  	};

	always #4 clk = ~clk;

	initial begin
    	$dumpfile("build/snail_mealy.vcd");
    	$dumpvars(0, tb_snail_mealy);
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
			// Check the output before the rising edges, don't wait.
			// Because Mealy machine output depends on the current state and
			// a state, when a change the output is immediatly set.
			// This is different for the Moore machine implementation.
			// This is an actual implication of the `when` question when
			// choosing an FSM type.
    	    // @(posedge clk);
    	    #1;

    	    assert (y_mealy === sim[i][0])
    	        else $fatal(
					1,
    	            "Mealy: step=%0d a=%b expected=%b actual=%b",
    	            i, a, sim[i][0], y_mealy
    	        );

			// Wait for edge after output check.
    	    @(posedge clk);
    	end

		$display("PASS: snail_mealy behavior");
		$finish;
	end
endmodule

