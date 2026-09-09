module top (
    input  logic clk,
    output logic led_V13
);
    logic [25:0] counter = '0;

    always_ff @(posedge clk)
        counter <= counter + 1'b1;

    // The dock LED is active-low.
    always_comb
        led_V13 = ~counter[25];
endmodule
