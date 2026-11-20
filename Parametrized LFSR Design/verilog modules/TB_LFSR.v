/*
    MODULE: TB_LFSR.v
    DESCRIPTION:
        Testbench for verifying 8-bit LFSR operation.
        Uses tasks for automated checking and golden sequence comparison.
        Tests reset, load, enable, and sequence generation functionality.
*/


`timescale 1ns / 1ps

module tb_lfsr;

    //* ---------------------------------------------------------
    //* 1. Testbench Signals
    //* ---------------------------------------------------------
    reg clk;
    reg rst_n;
    reg en;
    reg load;
    reg [15:0] init_state;
    wire [15:0] random_out;
    
    // Extract 8-bit output (since we're testing TYPE=1)
    wire [7:0] lfsr_out = random_out[7:0];
    
    // Test control
    reg [7:0] golden_seq [0:19];  // Golden sequence array (20 steps)
    integer error_count;           // Error counter
    integer test_pass;             // Test pass flag (1=pass, 0=fail)
    integer i;                     // General loop variable
    
    //* ---------------------------------------------------------
    //* 2. Clock Generation
    //* ---------------------------------------------------------
    // 10ns clock period = 100MHz
    initial clk = 0;
    always #5 clk = ~clk;
    
    //* ---------------------------------------------------------
    //* 3. LFSR Instantiation (TYPE=1 for 8-bit)
    //* ---------------------------------------------------------
    LFSR_top_if #(.LFSR_TYPE(1)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .load(load),
        .init_state(init_state),
        .random_out(random_out)
    );
    
    //* ---------------------------------------------------------
    //* 4. Initialize Golden Sequence with Hardcoded Values
    //* ---------------------------------------------------------
    initial begin
        // Golden sequence for 8-bit LFSR with TAPS = 8'b10111000
        // Initial state = 8'hAA, polynomial: x⁸ + x⁶ + x⁵ + x⁴ + 1
        // From the text file generated, we have:
        golden_seq[0] = 8'b10101010;
        golden_seq[1] = 8'b11010101;
        golden_seq[2] = 8'b01101010;
        golden_seq[3] = 8'b00110101;
        golden_seq[4] = 8'b00011010;
        golden_seq[5] = 8'b00001101;
        golden_seq[6] = 8'b10000110;
        golden_seq[7] = 8'b11000011;
        golden_seq[8] = 8'b11100001;
        golden_seq[9] = 8'b01110000;
        golden_seq[10] = 8'b00111000;
        golden_seq[11] = 8'b10011100;
        golden_seq[12] = 8'b11001110;
        golden_seq[13] = 8'b01100111;
        golden_seq[14] = 8'b10110011;
        golden_seq[15] = 8'b11011001;
        golden_seq[16] = 8'b11101100;
        golden_seq[17] = 8'b11110110;
        golden_seq[18] = 8'b11111011;
        golden_seq[19] = 8'b01111101;
        
        // Display first 5 values for verification
        $display("Golden sequence initialized:");
        for (i = 0; i < 5; i = i + 1) begin
            $display("  Step %0d: 8'b%b (0x%0h)", i, golden_seq[i], golden_seq[i]);
        end
    end
    
    //* ---------------------------------------------------------
    //* 5. is_valid_state Function (same logic as LFSR module)
    //* ---------------------------------------------------------
    function is_valid_state;
        input [7:0] state;
        begin
            is_valid_state = (state != 8'b0);
        end
    endfunction
    
    //* ---------------------------------------------------------
    //* 6. TASK: check_lfsr_sequence
    //* ---------------------------------------------------------
    task check_lfsr_sequence;
        input integer num_steps;
        reg [7:0] expected_val;
        integer step;
    begin
        $display("\n=== Starting Sequence Check ===");
        $display("Time %0t: Checking %0d steps against golden sequence", $time, num_steps);
        
        // 1) Verify the current (loaded) state equals the first golden value
        expected_val = golden_seq[0];
        if(lfsr_out !== expected_val) begin
            $display("ERROR at initial state: Expected 8'b%b, Got 8'b%b", expected_val, lfsr_out);
            error_count = error_count +1;
            test_pass =0;
        end else begin
            $display("OK initial state: 8'b%b (matches golden[0])", lfsr_out);
        end

        // 2) Now shift and check subsequent steps
        for (step = 1; step < num_steps; step = step + 1) begin
        @(posedge clk);
        #1;
        expected_val = golden_seq[step];
        if (lfsr_out !== expected_val) begin
            $display("ERROR at Step %0d: Expected 8'b%b, Got 8'b%b",
                     step, expected_val, lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("OK Step %0d: 8'b%b (matches golden)", step, lfsr_out);
        end

        // Check for all-zero state
        if (!is_valid_state(lfsr_out)) begin
            $display("ERROR at Step %0d: LFSR entered all-zero state!", step);
            error_count = error_count + 1;
            test_pass = 0;
        end
    end
        
        $display("=== Sequence Check Complete ===");
    end
    endtask
    
    //* ---------------------------------------------------------
    //* 7. TASK: run_lfsr_test
    //* ---------------------------------------------------------
    task run_lfsr_test;
        input [7:0] init_val;
        input integer num_steps;
    begin
        $display("\n=========================================");
        $display("     Running LFSR Sequence Test");
        $display("=========================================");
        $display("Time %0t: Initial seed = 8'b%b (0x%0h)", $time, init_val, init_val);
        
        // Apply reset (active low)
        rst_n = 0;
        en = 0;
        load = 0;
        init_state = {8'b0, init_val};  // Place seed in lower 8 bits
        repeat(3) @(posedge clk);  // Hold reset for 3 cycles
        #1;
        
        // Release reset
        rst_n = 1;
        @(posedge clk);
        #1;
        
        // Verify reset set all ones
        if (lfsr_out !== 8'hFF) begin
            $display("ERROR: Reset failed. Expected 8'hFF, Got 8'h%b", lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("Reset OK: state = 8'hFF (all ones as expected)");
        end
        
        // Load initial state
        load = 1;
        @(posedge clk);
        #1;
        
        // Verify load operation
        if (lfsr_out !== init_val) begin
            $display("ERROR: Load failed. Expected 8'b%b, Got 8'b%b", 
                     init_val, lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("Load OK: state = 8'b%b", lfsr_out);
        end
        
        // Release load and enable shifting
        load = 0;
        en = 1;
        
        // Verify initial state is valid (non-zero)
        if (!is_valid_state(lfsr_out)) begin
            $display("ERROR: Initial state is all zeros (invalid)!");
            error_count = error_count + 1;
            test_pass = 0;
        end
        
        // Run the sequence check against golden file
        check_lfsr_sequence(num_steps);
        
        // Disable after test
        en = 0;
        
        $display("=== LFSR Sequence Test Complete ===");
    end
    endtask
    
    //* ---------------------------------------------------------
    //* 8. TASK: test_load_zero_protection
    //* ---------------------------------------------------------
    task test_load_zero_protection;
    begin
        $display("\n=========================================");
        $display("     Testing Zero-Load Protection");
        $display("=========================================");
        
        // Apply reset
        rst_n = 0;
        en = 0;
        load = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        #1;
        
        // Try to load all zeros
        load = 1;
        init_state = 16'h0000;  // All zeros
        @(posedge clk);
        #1;
        
        // Should have been forced to all ones
        if (lfsr_out !== 8'hFF) begin
            $display("FAIL: Zero-load protection failed. Got 8'b%b instead of 8'hFF", lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("PASS: Zero-load protection works. Forced to 8'hFF");
        end
        
        load = 0;
        en = 0;
        
        $display("=== Zero-Load Test Complete ===");
    end
    endtask
    
    //* ---------------------------------------------------------
    //* 9. TASK: test_enable_gating
    //* ---------------------------------------------------------
    task test_enable_gating;
        reg [7:0] state_before;
    begin
        $display("\n=========================================");
        $display("     Testing Enable Gating");
        $display("=========================================");
        
        // Reset and load a known value
        rst_n = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        load = 1;
        init_state = {8'b0, 8'hA5};  // 8'b10100101
        @(posedge clk);
        load = 0;
        en = 0;  // Keep enable low
        #1;
        
        $display("State with en=0: 8'b%b", lfsr_out);
        state_before = lfsr_out;
        
        // Wait several cycles with enable low
        repeat(3) @(posedge clk);
        #1;
        
        $display("State after 3 cycles (en=0): 8'b%b", lfsr_out);
        
        // State should remain unchanged
        if (lfsr_out !== state_before) begin
            $display("FAIL: State changed while enable was low!");
            $display("  Before: 8'b%b, After: 8'b%b", state_before, lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("PASS: State unchanged when en=0");
        end
        
        // Now enable and verify state changes
        en = 1;
        @(posedge clk);
        #1;
        
        if (lfsr_out === state_before) begin
            $display("FAIL: State didn't change after enable!");
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("PASS: State changed to 8'b%b after en=1", lfsr_out);
        end
        
        en = 0;
        
        $display("=== Enable Gating Test Complete ===");
    end
    endtask
    
    //* ---------------------------------------------------------
    //* 10. Main Test Sequence
    //* ---------------------------------------------------------
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 1;
        en = 0;
        load = 0;
        init_state = 16'h0000;
        error_count = 0;
        test_pass = 1;  // Assume pass until proven otherwise
        
        $display("===========================================");
        $display("     LFSR Testbench Starting");
        $display("     Testing 8-bit LFSR (TYPE=1)");
        $display("     TAPS: x^8 + x^6 + x^5 + x^4 + 1");
        $display("===========================================");
        
        // Allow time for golden sequence to load
        repeat(5) @(posedge clk);
        
        // Test 1: Zero-load protection
        test_load_zero_protection();
        repeat(3) @(posedge clk);
        
        // Test 2: Enable gating behavior
        test_enable_gating();
        repeat(3) @(posedge clk);
        
        // Test 3: Full sequence test with golden comparison
        run_lfsr_test(8'hAA, 20);  // Seed = 0xAA, 20 steps
        
        // Final report
        $display("\n===========================================");
        $display("          TEST SUMMARY");
        $display("===========================================");
        if (test_pass && error_count == 0) begin
            $display("RESULT: ALL TESTS PASSED!");
            $display("Total Errors: %0d", error_count);
        end else begin
            $display("RESULT: TEST FAILED!");
            $display("Total Errors: %0d", error_count);
        end
        $display("===========================================");
        
        // End simulation
        #100;
        $finish;
    end
    
    //* ---------------------------------------------------------
    //* 11. Waveform Dumping (clean, essential signals only)
    //* ---------------------------------------------------------
    initial begin
        $dumpfile("tb_lfsr.vcd");
        $dumpvars(0, tb_lfsr.clk);     // Clock
        $dumpvars(0, tb_lfsr.rst_n);   // Reset
        $dumpvars(0, tb_lfsr.en);      // Enable
        $dumpvars(0, tb_lfsr.load);    // Load
        $dumpvars(0, tb_lfsr.lfsr_out); // 8-bit output only
    end
    
    //* ---------------------------------------------------------
    //* 12. Simulation Timeout Protection
    //* ---------------------------------------------------------
    initial begin
        #100000;  // 100us timeout
        $display("\nERROR: Simulation timeout reached!");
        $display("The testbench may be stuck or running too long");
        $finish;
    end

endmodule