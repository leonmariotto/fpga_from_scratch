module board (
	input logic clk,
	input logic reset,
	output logic led_V13
);
	localparam logic [31:0] LED_ADDRESS = 32'h0000_1000;

	logic memory_write;
	logic [31:0] data_address;
	logic [31:0] write_data;
	logic led_state;

	single_cycle #(.INST_MEM_FILE("blinky.hex"), .INST_MEM_WORDS(33)) core (
		.clk(clk),
		.reset(reset),
		.memory_write_out(memory_write),
		.data_address(data_address),
		.write_data_out(write_data)
	);

	always_ff @(posedge clk) begin
		if (reset)
			led_state <= 1'b0;
		else if (memory_write && data_address == LED_ADDRESS)
			led_state <= write_data[0];
	end

	// The Tang Console dock LED is active-low.
	assign led_V13 = ~led_state;
endmodule
