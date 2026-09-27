module tb_alu;
	logic [31:0] a, b, c;
	logic [1:0] alu_control;
	logic zero;

	alu dut (.*);

	task automatic check(input logic [31:0] test_a, test_b,
		input logic [1:0] operation, input logic [31:0] expected);
		a = test_a;
		b = test_b;
		alu_control = operation;
		#1;
		assert (c === expected && zero === (expected == 0))
			else $fatal(1, "op=%b a=%h b=%h: c=%h zero=%b",
						alu_control, a, b, c, zero);
	endtask

	initial begin
		check(32'd17, 32'd25, 2'b00, 32'd42);
		check(32'hffff_ffff, 32'd1, 2'b00, 32'd0);
		check(32'd25, 32'd17, 2'b01, 32'd8);
		check(32'd17, 32'd25, 2'b01, 32'hffff_fff8);
		check(32'hf0f0_55aa, 32'h0ff0_0f0f, 2'b10, 32'h00f0_050a);
		check(32'hf0f0_5000, 32'h0f00_05aa, 2'b11, 32'hfff0_55aa);
		$display("PASS: tb_alu");
		$finish;
	end
endmodule
