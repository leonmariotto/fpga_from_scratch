`timescale 1ns/1ps

module tb_alu;
    localparam int N = 32;

    logic [N-1:0] a;
    logic [N-1:0] b;
    logic [1:0]   alu_control;
    logic [N-1:0] c;
    logic [N-1:0] expected;

    integer vector_file;
    integer scan_result;
    integer vector_count;
    integer error_count;

    alu #(.N(N)) dut (
        .a           (a),
        .b           (b),
        .alu_control (alu_control),
        .c           (c)
    );

    initial begin
        $dumpfile("build/alu.vcd");
        $dumpvars(0, tb_alu);

        a = '0;
        b = '0;
        alu_control = '0;
        expected = '0;
        vector_count = 0;
        error_count = 0;

        vector_file = $fopen("alu_vectors.txt", "r");
        if (vector_file == 0)
            $fatal(1, "Could not open alu_vectors.txt");

        // Each row contains: alu_control, a, b, expected c.
        while (!$feof(vector_file)) begin
            scan_result = $fscanf(
                vector_file, "%b %h %h %h\n",
                alu_control, a, b, expected
            );

            if (scan_result == 4) begin
                #1;
                vector_count = vector_count + 1;
                if (c !== expected) begin
                    $error(
                        "vector %0d: control=%02b a=%08h b=%08h c=%08h expected=%08h",
                        vector_count, alu_control, a, b, c, expected
                    );
                    error_count = error_count + 1;
                end
            end else if (scan_result != -1) begin
                $fatal(1, "Malformed test vector after vector %0d", vector_count);
            end
        end

        $fclose(vector_file);

        if (vector_count == 0)
            $fatal(1, "No ALU test vectors were loaded");
        if (error_count != 0)
            $fatal(1, "FAIL: %0d of %0d ALU vectors failed", error_count, vector_count);

        $display("PASS: all %0d ALU vectors passed", vector_count);
        $finish;
    end
endmodule
