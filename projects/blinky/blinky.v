module top (
    input  wire clk,
    output wire led_V13
);
    reg [25:0] counter = 0;

    always @(posedge clk)
        counter <= counter + 1'b1;

    // The dock LED is active-low.
    assign led_V13 = ~counter[25];
endmodule
