module tb_board_blinky;
	logic clk = 0;
	logic reset;
	logic led_V13;

	board dut (.*);
	always #5 clk = ~clk;

	task automatic tick;
		@(posedge clk); #1;
	endtask

	initial begin
		reset = 1;
		tick();
		reset = 0;

		// The startup code builds 0x1000 and stores one to the LED register.
		repeat (20) begin
			if (dut.led_state === 1'b1)
				break;
			tick();
		end
		assert (dut.led_state === 1'b1 && led_V13 === 1'b0)
			else $fatal(1, "CPU did not turn the active-low LED on");

		// Shorten the two nested delay loops for simulation.
		wait (dut.core.pc == 32'h0000_0044);
		dut.core.regs.rf[3] = 32'd1;
		dut.core.regs.rf[4] = 32'd1;
		repeat (8) tick();
		assert (dut.led_state === 1'b0 && led_V13 === 1'b1)
			else $fatal(1, "CPU did not turn the active-low LED off");

		$display("PASS: tb_board_blinky");
		$finish;
	end
endmodule
