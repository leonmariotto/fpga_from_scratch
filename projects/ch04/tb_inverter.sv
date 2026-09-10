`timescale 1ns/1ps

module tb_inverter;
    logic in;
    logic out;

    inverter dut (.*);

    initial begin
        $dumpfile("build/inverter.vcd");
        $dumpvars(0, tb_inverter);

        in = 1'b0;
        #10;
        assert (out === 1'b1) else $fatal(1, "~0 must be 1");

        in = 1'b1;
        #10;
        assert (out === 1'b0) else $fatal(1, "~1 must be 0");

        $display("PASS: inverter truth table");
        $finish;
    end
endmodule
