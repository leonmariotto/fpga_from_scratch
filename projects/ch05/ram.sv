module ram #(parameter N = 8, M = 32)
			(input logic 		clk,
			 input logic 		we,
			 input logic 		[N-1:0] addr,
			 input logic 		[M-1:0] din,
			 output logic 		[M-1:0] dout);
	logic [M-1:0] mem [2**N-1:0];

	always_ff @(posedge clk) begin
		if (we)
			mem[addr] <= din;

		dout <= mem[addr];
	end
	
endmodule

