module tb_extend;
	logic [31:7] Imm;
	logic [1:0] ImmSrc;
	logic [31:0] ImmExt;

	extend dut (.*);

	task automatic check(input logic [31:0] instruction,
						 input logic [1:0] source,
						 input logic [31:0] expected);
		Imm = instruction[31:7];
		ImmSrc = source;
		#1;
		assert (ImmExt === expected)
			else $fatal(1, "ImmSrc=%b instruction=%h: got %h, expected %h",
						ImmSrc, instruction, ImmExt, expected);
	endtask

	initial begin
		check(32'h7ff00013, 2'b00, 32'h000007ff); // I: largest positive
		check(32'h80000013, 2'b00, 32'hfffff800); // I: most negative
		check(32'h7e000fa3, 2'b01, 32'h000007ff); // S: largest positive
		check(32'h80000023, 2'b01, 32'hfffff800); // S: most negative
		check(32'h7e000fe3, 2'b10, 32'h00000ffe); // B: positive, aligned
		check(32'h80000063, 2'b10, 32'hfffff000); // B: most negative
		check(32'h7ffff06f, 2'b11, 32'h000ffffe); // J: largest positive
		check(32'h8000006f, 2'b11, 32'hfff00000); // J: most negative
		$display("PASS: tb_extend");
		$finish;
	end
endmodule
