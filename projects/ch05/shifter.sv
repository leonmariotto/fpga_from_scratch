
module shifter#(parameter N = 32, S = 2)
			(input logic	clk,
			 input logic	[S-1:0] sin,
			 output logic	[S-1:0] sout,
			 output logic	[N-1:0] Q);
	always_ff @(posedge clk) begin
		sout = Q[N-1:N-(1+S)];
		Q[S-1:0] <= sin;
		Q[N-1:S] <= Q[N-(1+S):0];
	end
endmodule

