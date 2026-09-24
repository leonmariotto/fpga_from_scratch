module prefix_adder #(parameter N = 4)
                    (input  logic [N-1:0] a, b,
                     input  logic         cin,
                     output logic [N-1:0] s,
                     output logic         cout);
    localparam LEVELS = $clog2(N);

    logic [N-1:0] propagate [0:LEVELS];
    logic [N-1:0] generate_term [0:LEVELS];
    logic [N:0]   carry;

    // Bit propagate/generate terms form level zero of the prefix tree.
    assign propagate[0] = a ^ b;
    assign generate_term[0] = a & b;

    generate
        for (genvar level = 0; level < LEVELS; level++) begin : prefix_level
            localparam int DISTANCE = 1 << level;

            for (genvar bit_index = 0; bit_index < N; bit_index++) begin : prefix_bit
                if (bit_index >= DISTANCE) begin : combine
                    assign generate_term[level + 1][bit_index] =
                        generate_term[level][bit_index] |
                        (propagate[level][bit_index] &
                         generate_term[level][bit_index - DISTANCE]);
                    assign propagate[level + 1][bit_index] =
                        propagate[level][bit_index] &
                        propagate[level][bit_index - DISTANCE];
                end else begin : pass_through
                    assign generate_term[level + 1][bit_index] =
                        generate_term[level][bit_index];
                    assign propagate[level + 1][bit_index] =
                        propagate[level][bit_index];
                end
            end
        end
    endgenerate

    assign carry[0] = cin;

    generate
        for (genvar bit_index = 0; bit_index < N; bit_index++) begin : carry_bit
            assign carry[bit_index + 1] = generate_term[LEVELS][bit_index] |
                (propagate[LEVELS][bit_index] & cin);
            assign s[bit_index] = propagate[0][bit_index] ^ carry[bit_index];
        end
    endgenerate

    assign cout = carry[N];
endmodule
