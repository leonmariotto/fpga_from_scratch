
`timescale 1ns/1ps

module tb_counter;
    localparam int N = 32;
    localparam int I = 4;

	logic clk = 1'b0;
	logic reset = 1'b0;
	logic load = 1'b0;
	logic [N-1:0] D;
	logic [N-1:0] Q;

    counter #(.N(N), .I(I)) dut (
        .clk         	(clk),
        .reset          (reset),
        .load          (load),
        .Q           	(Q),
        .D           	(D)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/counter.vcd");
        $dumpvars(0, tb_counter);

		reset = 1;
        @(posedge clk);
        #1;
        assert (Q === 32'h0000_0000)
            else $fatal(1, "after reset: Q=%08h", Q);

		reset = 0;
        @(posedge clk);
        #1;
        assert (Q === 32'h0000_0004)
            else $fatal(1, "first increment: Q=%08h", Q);

		D = 32'h0000_1000;
		load = 1;
        @(posedge clk);
        #1;
        assert (Q === 32'h0000_1000)
            else $fatal(1, "after load: Q=%08h", Q);

		D = 32'hffff_ffff;
		load = 1;
        @(posedge clk);
        #1;
        assert (Q === 32'hffff_ffff)
            else $fatal(1, "after load: Q=%08h", Q);

		load = 0;
        @(posedge clk);
        #1;
        assert (Q === 32'h0000_0003)
            else $fatal(1, "overflow: Q=%08h", Q);

        $display("PASS: counter tests passed");
        $finish;
    end
endmodule
