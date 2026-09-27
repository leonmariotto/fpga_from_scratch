module tb_alu_decoder;
	logic [1:0] ALUOp;
	logic [2:0] funct3;
	logic op_5, funct7_5;
	logic [2:0] ALUControl;

	alu_decoder dut (.*);

	task automatic check(input logic [1:0] test_aluop,
		input logic [2:0] test_funct3, input logic test_op5,
		input logic test_funct7_5, input logic [2:0] expected);
		ALUOp = test_aluop;
		funct3 = test_funct3;
		op_5 = test_op5;
		funct7_5 = test_funct7_5;
		#1;
		assert (ALUControl === expected)
			else $fatal(1, "Got ALUControl=%b, expected %b", ALUControl, expected);
	endtask

	initial begin
		check(2'b00, 3'bxxx, 1'bx, 1'bx, 3'b000); // address addition
		check(2'b01, 3'bxxx, 1'bx, 1'bx, 3'b001); // branch subtraction
		check(2'b10, 3'b000, 0, 0, 3'b000); // addi/add
		check(2'b10, 3'b000, 0, 1, 3'b000); // addi, not sub
		check(2'b10, 3'b000, 1, 0, 3'b000); // add
		check(2'b10, 3'b000, 1, 1, 3'b001); // sub
		check(2'b10, 3'b010, 1, 0, 3'b101); // slt
		check(2'b10, 3'b110, 1, 0, 3'b011); // or
		check(2'b10, 3'b111, 1, 0, 3'b010); // and
		$display("PASS: tb_alu_decoder");
		$finish;
	end
endmodule
