
module alu #(parameter N = 32)
			(input logic [N-1:0] a, b,
				input logic [1:0] alu_control,
				output logic [N-1:0] c);
	always_comb
		case (alu_control)
			2'b00: c = a + b;
			2'b01: c = a - b;
			2'b10: c = a & b;
			2'b11: c = a | b;
		endcase
endmodule

