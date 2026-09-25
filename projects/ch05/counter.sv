

module counter #(parameter N = 32, I = 4)
			(input logic clk,
			input logic reset,
			input logic load,
			input logic [N-1:0] D,
			output logic [N-1:0] Q);
	always_ff @(posedge clk) begin
		if (reset)
			Q <= 0;
		else if (load)
			Q <= D;
		else
			Q <= Q + I;
	end
endmodule
