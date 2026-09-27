module tb_control_unit;
	logic [6:0] op;
	logic [2:0] funct3;
	logic funct7_5, zero;
	logic RegWrite, ALUSrc, MemWrite, PCSrc, Jump;
	logic [1:0] ImmSrc, ResultSrc;
	logic [2:0] ALUControl;

	control_unit dut (.*);

	initial begin
		op = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; zero = 0; #1;
		assert (!PCSrc && !RegWrite && ALUControl == 3'b001)
			else $fatal(1, "Untaken beq controls are wrong");
		zero = 1; #1;
		assert (PCSrc) else $fatal(1, "Taken beq did not select target PC");

		op = 7'b1101111; funct3 = 3'b000; funct7_5 = 0; zero = 0; #1;
		assert (PCSrc && Jump && RegWrite && ImmSrc == 2'b11 && ResultSrc == 2'b10)
			else $fatal(1, "jal controls are wrong");

		op = 7'b0110011; funct3 = 3'b000; funct7_5 = 1; zero = 0; #1;
		assert (RegWrite && !ALUSrc && !MemWrite && ALUControl == 3'b001)
			else $fatal(1, "sub controls are wrong");

		op = 7'b0010011; funct3 = 3'b111; funct7_5 = 0; zero = 0; #1;
		assert (RegWrite && ALUSrc && ALUControl == 3'b010 && !PCSrc)
			else $fatal(1, "andi controls are wrong");

		$display("PASS: tb_control_unit");
		$finish;
	end
endmodule
