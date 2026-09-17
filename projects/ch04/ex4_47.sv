module ex4_47(input logic clk,
				input logic d,
				output logic q);
	logic tmp;

	always_ff @(posedge clk)
		begin
			tmp <= d;
			q <= tmp;
		end
endmodule
