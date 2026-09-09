`timescale 1ns/1ps

module tb_blinky;
    logic clk = 1'b0;
    logic led_V13;

    top dut (
        .clk(clk),
        .led_V13(led_V13)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/blinky.vcd");
        $dumpvars(0, tb_blinky);

        #1;
        if (led_V13 !== 1'b1)
            $fatal(1, "LED should initially be off");

        repeat (3) @(posedge clk);
        #1;
        if (dut.counter !== 26'd3)
            $fatal(1, "counter did not increment on each rising edge");

        // Start near the transition so the test need not simulate 2^25 cycles.
        @(negedge clk);
        dut.counter = 26'h1ff_ffff;
        @(posedge clk);
        #1;
        if (dut.counter !== 26'h200_0000 || led_V13 !== 1'b0)
            $fatal(1, "LED did not turn on when counter[25] became high");

        $display("PASS: blinky counter and active-low LED behave as expected");
        $finish;
    end
endmodule
