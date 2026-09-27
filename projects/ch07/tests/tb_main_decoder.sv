module tb_main_decoder;
	logic [6:0] op;
	logic RegWrite, ALUSrc, MemWrite, Branch, Jump;
	logic [1:0] ImmSrc, ResultSrc, ALUOp;

	main_decoder dut (.*);

	task automatic check(input logic [6:0] test_op,
		input logic exp_regwrite, input logic [1:0] exp_immsrc,
		input logic exp_alusrc, input logic exp_memwrite,
		input logic [1:0] exp_resultsrc, input logic exp_branch,
		input logic [1:0] exp_aluop, input logic exp_jump);
		op = test_op;
		#1;
		assert ({RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc,
				 Branch, ALUOp, Jump} ===
				{exp_regwrite, exp_immsrc, exp_alusrc, exp_memwrite,
				 exp_resultsrc, exp_branch, exp_aluop, exp_jump})
			else $fatal(1, "Wrong controls for opcode %b", op);
	endtask

	initial begin
		check(7'b0000011, 1, 2'b00, 1, 0, 2'b01, 0, 2'b00, 0); // lw
		check(7'b0100011, 0, 2'b01, 1, 1, 2'b00, 0, 2'b00, 0); // sw
		check(7'b0110011, 1, 2'b00, 0, 0, 2'b00, 0, 2'b10, 0); // R
		check(7'b1100011, 0, 2'b10, 0, 0, 2'b00, 1, 2'b01, 0); // beq
		check(7'b0010011, 1, 2'b00, 1, 0, 2'b00, 0, 2'b10, 0); // I ALU
		check(7'b1101111, 1, 2'b11, 0, 0, 2'b10, 0, 2'b10, 1); // jal
		check(7'b1111111, 0, 2'b00, 0, 0, 2'b00, 0, 2'b00, 0); // illegal
		$display("PASS: tb_main_decoder");
		$finish;
	end
endmodule
