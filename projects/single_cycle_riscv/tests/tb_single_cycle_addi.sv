module tb_single_cycle_addi;
	logic clk = 0;
	logic reset;
	single_cycle dut (
		.clk(clk),
		.reset(reset)
	);
	always #5 clk = ~clk;

	function automatic [31:0] encode_addi(input [4:0] rd, rs1,
										 input logic signed [11:0] imm);
		encode_addi = {imm, rs1, 3'b000, rd, 7'b0010011};
	endfunction

	task automatic tick; @(posedge clk); #1; endtask
	task automatic run_case(input [31:0] lhs,
		input logic signed [11:0] immediate, input [31:0] expected);
		logic [31:0] instruction;
		instruction = encode_addi(5'd3, 5'd1, immediate);
		dut.regs.rf[1] = lhs;
		dut.regs.rf[3] = 32'hfeed_face;
		dut.inst_mem.mem[0] = instruction;
		reset = 1; tick();
		reset = 0; #1;
		assert (dut.imm_ext === {{20{immediate[11]}}, immediate})
			else $fatal(1, "addi immediate was extended incorrectly");
		tick();
		assert (dut.regs.rf[3] === expected)
			else $fatal(1, "addi lhs=%h imm=%0d produced %h",
						lhs, immediate, dut.regs.rf[3]);
		assert (dut.pc === 32'd4) else $fatal(1, "addi advanced PC to %h", dut.pc);
	endtask

	initial begin
		// addi dst, src1, immediate
		// first param is src1, second is immediate, end is expected.
		run_case(32'd10, 12'sd31, 32'd41); // 10 + 31 = 41
		run_case(32'd10, -12'sd7, 32'd3);
		run_case(32'hffff_ffff, 12'sd1, 32'd0);
		$display("PASS: tb_single_cycle_addi");
		$finish;
	end
endmodule
