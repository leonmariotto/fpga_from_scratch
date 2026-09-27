module tb_single_cycle_beq;
	logic clk = 0;
	logic reset;
	single_cycle dut (
		.clk(clk),
		.reset(reset)
	);
	always #5 clk = ~clk;

	function automatic [31:0] encode_beq(input [4:0] rs1, rs2,
									  input logic signed [12:0] imm);
		encode_beq = {imm[12], imm[10:5], rs2, rs1, 3'b000,
					  imm[4:1], imm[11], 7'b1100011};
	endfunction

	task automatic tick; @(posedge clk); #1; endtask
	task automatic run_case(input [31:0] lhs, rhs,
		input logic signed [12:0] offset, input [31:0] expected_pc);
		logic [31:0] instruction;
		instruction = encode_beq(5'd1, 5'd2, offset);
		dut.regs.rf[1] = lhs;
		dut.regs.rf[2] = rhs;
		dut.regs.rf[3] = 32'hcafe_babe;
		dut.inst_mem.mem[0] = instruction;
		reset = 1; tick();
		reset = 0; #1;
		assert (dut.pc_src === (lhs == rhs))
			else $fatal(1, "beq decision is wrong for %h and %h", lhs, rhs);
		tick();
		assert (dut.pc === expected_pc)
			else $fatal(1, "beq selected PC=%h, expected %h", dut.pc, expected_pc);
		assert (dut.regs.rf[3] === 32'hcafe_babe)
			else $fatal(1, "beq unexpectedly wrote a register");
	endtask

	initial begin
		run_case(32'h1234, 32'h1234, 13'sd8, 32'd8);
		run_case(32'h1234, 32'h5678, 13'sd8, 32'd4);
		run_case(32'hffff_ffff, 32'hffff_ffff, -13'sd4, 32'hffff_fffc);
		$display("PASS: tb_single_cycle_beq");
		$finish;
	end
endmodule
