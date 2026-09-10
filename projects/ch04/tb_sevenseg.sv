`timescale 1ns/1ps

module tb_sevenseg;
	logic [3:0] data;
	logic [6:0] segments;

    sevenseg dut (
		.data (data),
		.segments (segments)
	);

    initial begin
        $dumpfile("build/gates.vcd");
        $dumpvars(0, tb_sevenseg);

		data = 0;
		#1;
		assert (segments == 7'b111_1110) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 1;
		#1;
		assert (segments == 7'b011_0000) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 2;
		#1;
		assert (segments == 7'b110_1101) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 3;
		#1;
		assert (segments == 7'b111_1001) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 4;
		#1;
		assert (segments == 7'b011_0011) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 5;
		#1;
		assert (segments == 7'b101_1011) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 6;
		#1;
		assert (segments == 7'b101_1111) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 7;
		#1;
		assert (segments == 7'b111_0000) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 8;
		#1;
		assert (segments == 7'b111_1111) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 9;
		#1;
		assert (segments == 7'b111_0011) else $fatal(1, "data=%d segments=%06b", data, segments);
		data = 12;
		#1;
		assert (segments == 7'b000_0000) else $fatal(1, "data=%d segments=%06b", data, segments);

        $display("PASS: gates truth table");
        $finish;
    end
endmodule

