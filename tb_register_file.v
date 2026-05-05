/*

tb_register_file is a unified testbench for register_file_strcut and register_file_rtl.
It verifes:
    writing
    reading
    reset
    Z-release on write (contention avoidance)
    X-propagation on invalid address
    identical behavior of both implementations

Parts of the Code Structure:
    PART 1. Defining signals and parameters (the inputs and outputs to modules + drivers for the testbench itself)
    PART 2. Instantiating both implementations
    PART 3. Preparing the test setup
    PART 4. Tasks
        4.1. TASK 1: Reset both DUTs
        4.2. TASK 2: Write the same value to both DUTs
        4.3. TASK 3: Read both DUTs and verify against expected
        4.4. TASK 4: Read with invalid address -> We expect x on both buses
        4.5. TASK 5: Verify bus is Hi‑Z when DUT is in write mode and TB is silent
    PART 5: Main Test Sequence

*/

`timescale 1ns/1ps // time units of 1ns, with resolution of 1ps

module tb_register_file;

    // ======================== PART 1: SIGNAL DEFINITION ========================
    // ------------------------- Parameters -------------------------
    parameter CLK_PERIOD = 10; // 100MHz clock

    // ------------------------- Signals Common between both DUTs -------------------------
    reg clk;
    reg rst_n;
    reg rd_wr;
    reg [1:0] addr;

    // ------------------------- Output signals for both DUTs -------------------------
    wire [3:0] data_struct;
    wire [3:0] data_rtl;

    // ------------- testbench drivers for handling the bidirectional bus -------------
    reg  [3:0]  tb_dout_s;    // value TB wants to write (structural)
    reg         tb_drv_s;     // 1 means that TB is driving data_struct
    reg  [3:0]  tb_dout_r;    // value TB wants to write (RTL)
    reg         tb_drv_r;     // 1 = TB is driving data_rtl

    // Continuous assignments: TB either drives or goes Hi‑Z
    assign data_struct = (tb_drv_s) ? tb_dout_s : 4'bzzzz;
    assign data_rtl    = (tb_drv_r) ? tb_dout_r : 4'bzzzz;

    // ========================   END OF PART 1   ========================
    


    // ======================== PART 2: INSTANTIOANTIONS ========================
    // --- Structural DUT ---
    register_file_struct u_struct (
        .clk    (clk),
        .rst_n  (rst_n),
        .rd_wr (rd_wr),
        .addr   (addr),
        .data   (data_struct)
    );

    // --- RTL DUT ---
    register_file_rtl u_rtl (
        .clk    (clk),
        .rst_n  (rst_n),
        .rd_wr (rd_wr),
        .addr   (addr),
        .data   (data_rtl)
    );

    // ========================   END OF PART 2   ========================



    // ======================== PART 3: PREPARING THE TEST SETUP ========================
    // clk generator
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    // score keeping
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // ======================== END OF PART 3 ========================



    // ======================== PART 4: TASKS ========================
    // ==== TASK 1: Reset both DUTs ====
    task reset_duts:
        begin
            $display("[%0t] --- RESET ---", $time);
            rst_n     = 1'b0;
            rd_wrn    = 1'b0;
            addr      = 2'b00;
            tb_drv_s  = 1'b0;
            tb_drv_r  = 1'b0;
            #(CLK_PERIOD);
            rst_n     = 1'b1;
            #(CLK_PERIOD);
        end
    endtask

    // ==== TASK 2: Write the same value to both DUTs ====
    task write_both;
        input [1:0] a;
        input [3:0] val;
        begin
            @(negedge clk);
            addr      = a;
            rd_wrn    = 1'b0; // write mode
            tb_drv_s  = 1'b1;
            tb_dout_s = val;
            tb_drv_r  = 1'b1;
            tb_dout_r = val;
            @(posedge clk) // capture
            #1;
            tb_drv_s  = 1'b0; // release both buses
            tb_drv_r  = 1'b0;
            rd_wrn    = 1'b1;
            $display("[%0t] WRITE addr=%b data=%b", $time, a, val);
        end
    endtask

    // ==== TASK 3: Read both DUTs and verify against expected ====
    task read_and_check;
        input [1:0] a;
        input [3:0] expected;
        reg   [3:0] got_s, got_r;
        begin
            test_count = test_count + 1;
            addr     = a;
            rd_wrn   = 1'b1; // read mode
            tb_drv_s = 1'b0; // TB releases buses — DUTs drive
            tb_drv_r = 1'b0;
            #5;
            got_s = data_struct;
            got_r = data_rtl;
            $display("[%0t] READ  addr=%b: struct=%b, rtl=%b (expected %b)",
                     $time, a, got_s, got_r, expected);
            if (got_s === expected) begin
                $display("       struct: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("       struct: FAIL (got %b, expected %b)", got_s, expected);
                fail_count = fail_count + 1;
            end

            if (got_r === expected) begin
                $display("       rtl:    PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("       rtl:    FAIL (got %b, expected %b)", got_r, expected);
                fail_count = fail_count + 1;
            end

            rd_wrn = 1'b0;
        end
    endtask

    // ==== TASK 4: Read with invalid address -> We expect x on both buses ====
    task read_and_check_x;
        input [1:0] a;
        reg   [3:0] got_s, got_r;
        begin
            test_count = test_count + 1;
            addr     = a;
            rd_wrn   = 1'b1;
            tb_drv_s = 1'b0;
            tb_drv_r = 1'b0;
            #5;
            got_s = data_struct;
            got_r = data_rtl;
            $display("[%0t] READ-X addr=%b: struct=%b, rtl=%b", $time, a, got_s, got_r);

            // Must NOT be a clean 0/1 value — any x or z bit means PASS
            if (got_s !== 4'b0000 && got_s !== 4'b0001 && got_s !== 4'b0010 &&
                got_s !== 4'b0011 && got_s !== 4'b0100 && got_s !== 4'b0101 &&
                got_s !== 4'b0110 && got_s !== 4'b0111 && got_s !== 4'b1000 &&
                got_s !== 4'b1001 && got_s !== 4'b1010 && got_s !== 4'b1011 &&
                got_s !== 4'b1100 && got_s !== 4'b1101 && got_s !== 4'b1110 &&
                got_s !== 4'b1111) begin
                $display("       struct: PASS (unknown: %b)", got_s);
                pass_count = pass_count + 1;
            end else begin
                $display("       struct: FAIL (got clean %b, expected X)", got_s);
                fail_count = fail_count + 1;
            end

            if (got_r !== 4'b0000 && got_r !== 4'b0001 && got_r !== 4'b0010 &&
                got_r !== 4'b0011 && got_r !== 4'b0100 && got_r !== 4'b0101 &&
                got_r !== 4'b0110 && got_r !== 4'b0111 && got_r !== 4'b1000 &&
                got_r !== 4'b1001 && got_r !== 4'b1010 && got_r !== 4'b1011 &&
                got_r !== 4'b1100 && got_r !== 4'b1101 && got_r !== 4'b1110 &&
                got_r !== 4'b1111) begin
                $display("       rtl:    PASS (unknown: %b)", got_r);
                pass_count = pass_count + 1;
            end else begin
                $display("       rtl:    FAIL (got clean %b, expected X)", got_r);
                fail_count = fail_count + 1;
            end

            rd_wrn = 1'b0;
        end
    endtask

    // ==== TASK 5: Verify bus is Hi‑Z when DUT is in write mode and TB is silent ====
    task check_bus_z_during_write;
        input [1:0] a;
        reg   [3:0] got_s, got_r;
        begin
            test_count = test_count + 1;
            addr     = a;
            rd_wrn   = 1'b0;            // write mode
            tb_drv_s = 1'b0;            // TB not driving
            tb_drv_r = 1'b0;
            #5;
            got_s = data_struct;
            got_r = data_rtl;
            $display("[%0t] CHK-Z addr=%b: struct=%b, rtl=%b", $time, a, got_s, got_r);

            if (got_s === 4'bzzzz) begin
                $display("       struct: PASS (Hi-Z)");
                pass_count = pass_count + 1;
            end else begin
                $display("       struct: FAIL (expected Z, got %b)", got_s);
                fail_count = fail_count + 1;
            end

            if (got_r === 4'bzzzz) begin
                $display("       rtl:    PASS (Hi-Z)");
                pass_count = pass_count + 1;
            end else begin
                $display("       rtl:    FAIL (expected Z, got %b)", got_r);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ======================== END OF PART 4 ========================



    // ======================== PART 5: MAIN TEST SEQUENCE ========================
    initial begin
        $display("============================================================");
        $display(" REGISTER FILE TESTBENCH — Structural vs. RTL");
        $display("============================================================");

        // --- Power‑on defaults ---
        rst_n     = 1'b0;
        rd_wrn    = 1'b0;
        addr      = 2'b00;
        tb_dout_s = 4'b0000;
        tb_dout_r = 4'b0000;
        tb_drv_s  = 1'b0;
        tb_drv_r  = 1'b0;
        #(CLK_PERIOD * 2);

        // --- Phase 1: Reset, verify all zero ---
        reset_duts();
        read_and_check(2'b00, 4'b0000);
        read_and_check(2'b01, 4'b0000);
        read_and_check(2'b10, 4'b0000);
        read_and_check(2'b11, 4'b0000);

        // --- Phase 2: Write unique values ---
        write_both(2'b00, 4'b1010);
        write_both(2'b01, 4'b0101);
        write_both(2'b10, 4'b1100);
        write_both(2'b11, 4'b0011);
        read_and_check(2'b00, 4'b1010);
        read_and_check(2'b01, 4'b0101);
        read_and_check(2'b10, 4'b1100);
        read_and_check(2'b11, 4'b0011);

        // --- Phase 3: Overwrite one, check others unchanged ---
        write_both(2'b01, 4'b1111);
        read_and_check(2'b00, 4'b1010);
        read_and_check(2'b01, 4'b1111);
        read_and_check(2'b10, 4'b1100);
        read_and_check(2'b11, 4'b0011);

        // --- Phase 4: Reset clears everything ---
        reset_duts();
        read_and_check(2'b00, 4'b0000);
        read_and_check(2'b01, 4'b0000);
        read_and_check(2'b10, 4'b0000);
        read_and_check(2'b11, 4'b0000);

        // --- Phase 5: Hi‑Z test ---
        write_both(2'b00, 4'b1010);
        check_bus_z_during_write(2'b00);
        check_bus_z_during_write(2'b11);

        // --- Phase 6: X‑propagation — invalid address on read ---
        read_and_check_x(2'bxx);
        read_and_check_x(2'bzz);
        read_and_check_x(2'bx0);
        read_and_check_x(2'bz1);

        // --- Phase 7: Back‑to‑back writes/reads ---
        write_both(2'b00, 4'b0001);
        write_both(2'b01, 4'b0010);
        write_both(2'b10, 4'b0100);
        write_both(2'b11, 4'b1000);
        read_and_check(2'b00, 4'b0001);
        read_and_check(2'b01, 4'b0010);
        read_and_check(2'b10, 4'b0100);
        read_and_check(2'b11, 4'b1000);

        write_both(2'b11, 4'b0000);
        write_both(2'b10, 4'b0000);
        write_both(2'b01, 4'b0000);
        write_both(2'b00, 4'b0000);
        read_and_check(2'b00, 4'b0000);
        read_and_check(2'b01, 4'b0000);
        read_and_check(2'b10, 4'b0000);
        read_and_check(2'b11, 4'b0000);

        // --- Phase 8: All‑ones / all‑zeros pattern ---
        write_both(2'b00, 4'b1111);
        write_both(2'b01, 4'b0000);
        write_both(2'b10, 4'b1111);
        write_both(2'b11, 4'b0000);
        read_and_check(2'b00, 4'b1111);
        read_and_check(2'b01, 4'b0000);
        read_and_check(2'b10, 4'b1111);
        read_and_check(2'b11, 4'b0000);

        // --- Phase 9: Walking‑ones ---
        write_both(2'b00, 4'b0001); read_and_check(2'b00, 4'b0001);
        write_both(2'b00, 4'b0010); read_and_check(2'b00, 4'b0010);
        write_both(2'b00, 4'b0100); read_and_check(2'b00, 4'b0100);
        write_both(2'b00, 4'b1000); read_and_check(2'b00, 4'b1000);

        // --- Final report ---
        $display("");
        $display("============================================================");
        $display(" TEST SUMMARY");
        $display("============================================================");
        $display(" Total checks : %0d", test_count);
        $display(" Passed       : %0d", pass_count);
        $display(" Failed       : %0d", fail_count);
        if (fail_count == 0)
            $display(" ALL TESTS PASSED");
        else
            $display(" SOME TESTS FAILED — review log above");
        $display("============================================================");

        $finish;
    end

    // ======================== END OF PART 5 ========================

endmodule