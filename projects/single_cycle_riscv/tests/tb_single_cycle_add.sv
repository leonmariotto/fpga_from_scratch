module tb_single_cycle_add;
	logic clk = 0;
	logic reset;
	single_cycle dut (.*);
	always #5 clk = ~clk;

	function automatic [31:0] encode_add(input [4:0] rd, rs1, rs2);
		encode_add = {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011};
	endfunction

	task automatic tick; @(posedge clk); #1; endtask
	task automatic run_case(input [31:0] lhs, rhs, expected);
		logic [31:0] instruction;
		instruction = encode_add(5'd3, 5'd1, 5'd2);
		dut.regs.rf[1] = lhs;
		dut.regs.rf[2] = rhs;
		dut.regs.rf[3] = 32'hfeed_face;
		dut.inst_mem.mem[0] = instruction;
		reset = 1; tick();
		dut.inst_mem.dout = instruction;
		reset = 0; #1; tick();
		assert (dut.regs.rf[3] === expected)
			else $fatal(1, "add %h + %h produced %h", lhs, rhs, dut.regs.rf[3]);
		assert (dut.pc === 32'd4) else $fatal(1, "add advanced PC to %h", dut.pc);
		assert (!dut.memory_write) else $fatal(1, "add unexpectedly wrote memory");
	endtask

	initial begin
		run_case(32'd17, 32'd25, 32'd42);
		run_case(32'hffff_ffff, 32'd1, 32'd0);
		run_case(32'h8000_0000, 32'h8000_0000, 32'd0);
		$display("PASS: tb_single_cycle_add");
		$finish;
	end
endmodule
