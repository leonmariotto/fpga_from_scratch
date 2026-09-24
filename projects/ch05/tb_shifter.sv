
`timescale 1ns/1ps

module tb_shifter;
    localparam int N = 32;
    localparam int S = 2;

	logic [S-1:0] sin;
	logic [S-1:0] sout;
	logic [N-1:0] Q;
	logic clk = 1'b0;

    shifter #(.N(N), .S(S)) dut (
        .sin           	(sin),
        .clk         	(clk),
        .sout           (sout),
        .Q           	(Q)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/shifter.vcd");
        $dumpvars(0, tb_shifter);

        // The shifter has no reset, so give its register a known initial value.
        dut.Q = '0;

        sin = 2'b01;
        @(posedge clk);
        #1;
        assert (Q === 32'h0000_0001 && sout === 2'b00)
            else $fatal(1, "first shift: Q=%08h sout=%02b", Q, sout);

        sin = 2'b10;
        @(posedge clk);
        #1;
        assert (Q === 32'h0000_0006 && sout === 2'b00)
            else $fatal(1, "second shift: Q=%08h sout=%02b", Q, sout);

        $display("PASS: shifter tests passed");
        $finish;
    end
endmodule
