`timescale 1ns/1ps

module tb_gates;
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] y1;
    logic [3:0] y2;
    logic [3:0] y3;
    logic [3:0] y4;
    logic [3:0] y5;

    gates dut (
		.a		(a),
		.b		(b),
		.y1		(y1),
		.y2		(y2),
		.y3		(y3),
		.y4		(y4),
		.y5		(y5)
	);

    initial begin
        $dumpfile("build/gates.vcd");
        $dumpvars(0, tb_gates);

		for (int i = 0; i < 16; i++) begin
			for (int j = 0; j < 16; j++) begin
        		a = i[3:0];
        		b = j[3:0];

				#1;

				assert (y1 == (a & b))
					else $fatal(
						1,
						"a=%04b b=%04b y1=%04b expected=%04b",
						a, b, y1, a & b
					);
				assert (y2 == (a | b))
					else $fatal(
						1,
						"a=%04b b=%04b y2=%04b expected=%04b",
						a, b, y2, a | b
					);
				assert (y3 == (a ^ b))
					else $fatal(
						1,
						"a=%04b b=%04b y3=%04b expected=%04b",
						a, b, y3, a ^ b
					);
				assert (y4 == ~(a & b))
					else $fatal(
						1,
						"a=%04b b=%04b y4=%04b expected=%04b",
						a, b, y4, ~(a & b)
					);
				assert (y5 == ~(a | b))
					else $fatal(
						1,
						"a=%04b b=%04b y5=%04b expected=%04b",
						a, b, y5, ~(a | b)
					);
			end
		end
        $display("PASS: gates truth table");
        $finish;
    end
endmodule

