module tb_single_cycle_jal;
	logic clk = 0;
	logic reset;
	single_cycle dut (
		.clk(clk),
		.reset(reset)
	);
	always #5 clk = ~clk;

	function automatic [31:0] encode_jal(input [4:0] rd,
									  input logic signed [20:0] imm);
		encode_jal = {imm[20], imm[10:1], imm[11], imm[19:12],
					  rd, 7'b1101111};
	endfunction

	task automatic tick; @(posedge clk); #1; endtask
	task automatic run_case(input logic signed [20:0] offset,
		input [31:0] expected_pc);
		logic [31:0] instruction;
		instruction = encode_jal(5'd5, offset);
		dut.regs.rf[5] = 32'hfeed_face;
		dut.inst_mem.mem[0] = instruction;
		reset = 1; tick();
		reset = 0; #1;
		assert (dut.pc_src && dut.control_unit_i.Jump)
			else $fatal(1, "jal did not select its target");
		tick();
		assert (dut.pc === expected_pc)
			else $fatal(1, "jal selected PC=%h, expected %h", dut.pc, expected_pc);
		assert (dut.regs.rf[5] === 32'd4)
			else $fatal(1, "jal link value=%h, expected 00000004", dut.regs.rf[5]);
	endtask

	initial begin
		run_case(21'sd16, 32'd16);
		run_case(-21'sd4, 32'hffff_fffc);
		$display("PASS: tb_single_cycle_jal");
		$finish;
	end
endmodule
