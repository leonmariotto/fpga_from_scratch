
module ex4_17(input logic a, b, c, d, e, f, g,
			 output logic y);
	logic t1, t2, t3;
	always_comb
	begin 
		t1 = ~(a & b & c);
		t2 = ~(t1 & d);
		t3 = ~((f & g) | e);
		y = ~(~(t2 | t3));
	end
endmodule
