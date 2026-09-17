
module ex4_29(input logic clk,
					input logic reset,
					input logic ta, tb,
					output logic [1:0] la, lb);
	typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
	typedef enum logic [1:0] {GREEN, YELLOW, RED} outputtype;
	statetype state, nextstate;

	// state register
	always_ff @(posedge clk)
		if (reset) state <= S0;
		else state <= nextstate;

	// next state logic
	always_comb
		case (state)
			S0:			nextstate = statetype'(ta == 1'b1 ? S0 : S1);
			S1:			nextstate = S2;
			S2:			nextstate = statetype'(tb == 1'b1 ? S2 : S3);
			S3:			nextstate = S0;
			default:	nextstate = S0;
		endcase

	// output logic
	always_comb
		case (state)
			S0:	begin
				la = GREEN;
				lb = RED;
			end
			S1:	begin
				la = YELLOW;
				lb = RED;
			end
			S2:	begin
				la = RED;
				lb = GREEN;
			end
			// Note the syntax, far better than the begin .. end block.
			S3: {la, lb} = {RED, YELLOW};
			// S3:	begin
			// 	la = RED;
			// 	lb = YELLOW;
			// end
			default:	begin
				la = RED;
				lb = RED;
			end
		endcase
endmodule
