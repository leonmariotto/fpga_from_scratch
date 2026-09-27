module tb_ram;
	logic clk = 0;
	logic we;
	logic [3:0] addr;
	logic [31:0] din, dout;

	ram #(.N(4), .M(32)) dut (.*);
	always #5 clk = ~clk;

	task automatic tick;
		@(posedge clk); #1;
	endtask

	initial begin
		we = 1; addr = 4'h3; din = 32'h1234_5678;
		tick();
		we = 1; addr = 4'ha; din = 32'hdead_beef;
		tick();
		we = 0; addr = 4'h3;
		tick();
		assert (dout === 32'h1234_5678) else $fatal(1, "Synchronous read failed");

		addr = 4'ha;
		#2;
		assert (dout === 32'h1234_5678) else $fatal(1, "RAM read changed off-edge");
		tick();
		assert (dout === 32'hdead_beef) else $fatal(1, "Stored word was corrupted");

		$display("PASS: tb_ram");
		$finish;
	end
endmodule
