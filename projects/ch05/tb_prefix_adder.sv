`timescale 1ns/1ps

module tb_prefix_adder;
    localparam int N = 32;

    logic [N-1:0] a;
    logic [N-1:0] b;
    logic         cin;
    logic [N-1:0] s;
    logic         cout;
    logic [N-1:0] expected_s;
    logic         expected_cout;

    integer vector_file;
    integer scan_result;
    integer vector_count;
    integer error_count;

    prefix_adder #(.N(N)) dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .s    (s),
        .cout (cout)
    );

    initial begin
        $dumpfile("build/prefix_adder.vcd");
        $dumpvars(0, tb_prefix_adder);

        a = '0;
        b = '0;
        cin = 1'b0;
        expected_s = '0;
        expected_cout = 1'b0;
        vector_count = 0;
        error_count = 0;

        vector_file = $fopen("prefix_adder_vectors.txt", "r");
        if (vector_file == 0)
            $fatal(1, "Could not open prefix_adder_vectors.txt");

        // Each row contains: cin, a, b, expected sum, expected carry-out.
        while (!$feof(vector_file)) begin
            scan_result = $fscanf(
                vector_file, "%b %h %h %h %b\n",
                cin, a, b, expected_s, expected_cout
            );

            if (scan_result == 5) begin
                #1;
                vector_count = vector_count + 1;
                if ({cout, s} !== {expected_cout, expected_s}) begin
                    $error(
                        "vector %0d: cin=%b a=%08h b=%08h got=%b_%08h expected=%b_%08h",
                        vector_count, cin, a, b, cout, s,
                        expected_cout, expected_s
                    );
                    error_count = error_count + 1;
                end
            end else if (scan_result != -1) begin
                $fatal(1, "Malformed test vector after vector %0d", vector_count);
            end
        end

        $fclose(vector_file);

        if (vector_count == 0)
            $fatal(1, "No prefix-adder test vectors were loaded");
        if (error_count != 0)
            $fatal(1, "FAIL: %0d of %0d prefix-adder vectors failed",
                   error_count, vector_count);

        $display("PASS: all %0d prefix-adder vectors passed", vector_count);
        $finish;
    end
endmodule
