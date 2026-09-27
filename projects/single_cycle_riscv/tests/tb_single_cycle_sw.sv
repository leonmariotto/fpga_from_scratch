module tb_single_cycle_sw;
	logic clk = 0;
	logic reset;
	single_cycle dut (.*);
	always #5 clk = ~clk;

	function automatic [31:0] encode_sw(input [4:0] rs2, rs1,
									 input logic signed [11:0] imm);
		encode_sw = {imm[11:5], rs2, rs1, 3'b010, imm[4:0], 7'b0100011};
	endfunction

	task automatic tick; @(posedge clk); #1; endtask
	task automatic run_case(input [31:0] base, value,
		input logic signed [11:0] offset, input integer word_index);
		logic [31:0] instruction;
		logic [31:0] expected_address;
		instruction = encode_sw(5'd2, 5'd1, offset);
		expected_address = base + {{20{offset[11]}}, offset};
		dut.regs.rf[1] = base;
		dut.regs.rf[2] = value;
		dut.data_mem.mem[word_index] = 32'hfeed_face;
		dut.inst_mem.mem[0] = instruction;
		reset = 1; tick();
		dut.inst_mem.dout = instruction;
		reset = 0; #1;
		assert (dut.memory_write && dut.alu_result === expected_address)
			else $fatal(1, "sw address/control is wrong");
		tick();
		assert (dut.data_mem.mem[word_index] === value)
			else $fatal(1, "sw stored %h, expected %h",
						dut.data_mem.mem[word_index], value);
		assert (dut.pc === 32'd4) else $fatal(1, "sw advanced PC to %h", dut.pc);
	endtask

	initial begin
		run_case(32'd64, 32'h1234_5678, 12'sd12, 19);
		run_case(32'd64, 32'hdead_beef, -12'sd8, 14);
		$display("PASS: tb_single_cycle_sw");
		$finish;
	end
endmodule
