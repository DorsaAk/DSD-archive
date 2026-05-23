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
    reg [7:0] golden_seq [0:19];  // Golden sequence array
    integer error_count;           // Error counter
    integer test_pass;             // Test pass flag
    
    //* ---------------------------------------------------------
    //* 2. Clock Generation
    //* ---------------------------------------------------------
    // 10ns clock period = 100MHz
    always #5 clk = ~clk;

    //* ---------------------------------------------------------
    //* 3. LFSR Instantiation (TYPE=1 for 8-bit)
    //* ---------------------------------------------------------
    lfsr_top_if #(.LFSR_TYPE(1)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .load(load),
        .init_state(init_state),
        .random_out(random_out)
    );

    //* ---------------------------------------------------------
    //* 4. is_valid_state Function (from LFSR module)
    //* ---------------------------------------------------------
    // Verilog doesn't allow calling module functions directly,
    // so we implement the same check here for assertions
    function is_valid_state;
        input [7:0] state;
        begin
            is_valid_state = (state != 8'b0);
        end
    endfunction

    //* ---------------------------------------------------------
    //* 5. TASK: check_lfsr_sequence
    //* ---------------------------------------------------------
    task check_lfsr_sequence;
        input integer num_steps;
        reg [7:0] expected_val;
        integer i;
    begin
        $display("\n=== Starting Sequence Check ===");
        $display("Time %0t: Checking %0d steps", $time, num_steps);
        
        for (i = 0; i < num_steps; i = i + 1) begin
            @(posedge clk);  // Wait for next clock edge
            #1;  // Small delay to avoid race conditions
            
            expected_val = golden_seq[i];
            
            if (lfsr_out !== expected_val) begin
                $display("ERROR at Step %0d: Expected 8'b%b, Got 8'b%b", 
                         i, expected_val, lfsr_out);
                error_count = error_count + 1;
                test_pass = 0;
            end else begin
                $display("OK Step %0d: 8'b%b (matches expected)", i, lfsr_out);
            end
            
            // Check valid state using function
            if (!is_valid_state(lfsr_out)) begin
                $display("ERROR at Step %0d: LFSR entered all-zero state!", i);
                error_count = error_count + 1;
                test_pass = 0;
            end
        end
        
        $display("=== Sequence Check Complete ===");
    end
    endtask
    
    //* ---------------------------------------------------------
    //* 6. TASK: run_lfsr_test
    //* ---------------------------------------------------------
    task run_lfsr_test;
        input [7:0] init_val;
        input integer num_steps;
    begin
        $display("\n=== Starting LFSR Test ===");
        $display("Time %0t: Initial state = 8'b%b", $time, init_val);
        
        // Reset the LFSR
        rst_n = 0;
        en = 0;
        load = 0;
        init_state = {8'b0, init_val};  // Place in lower 8 bits
        repeat(3) @(posedge clk);  // Hold reset for 3 cycles
        #1;  // Small delay
        
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
            $display("Reset OK: state = 8'hFF");
        end
        
        // Load initial state
        load = 1;
        @(posedge clk);
        #1;
        
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
        
        // Check initial state validity
        if (!is_valid_state(lfsr_out)) begin
            $display("ERROR: Initial state is all zeros!");
            error_count = error_count + 1;
            test_pass = 0;
        end
        
        // Run sequence check
        check_lfsr_sequence(num_steps);
        
        $display("=== LFSR Test Complete ===");
    end
    endtask
    
    //* ---------------------------------------------------------
    //* 7. TASK: test_load_zero_protection
    //* ---------------------------------------------------------
    task test_load_zero_protection;
    begin
        $display("\n=== Testing Zero-Load Protection ===");
        
        // Reset
        rst_n = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        #1;
        
        // Try to load all zeros
        load = 1;
        init_state = 16'h0000;
        @(posedge clk);
        #1;
        
        // Should force to all ones
        if (lfsr_out !== 8'hFF) begin
            $display("ERROR: Zero-load protection failed. Got 8'b%b", lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("Zero-load protection OK: forced to 8'hFF");
        end
        
        load = 0;
        en = 0;
        $display("=== Zero-Load Test Complete ===");
    end
    endtask

    //* ---------------------------------------------------------
    //* 8. TASK: test_enable_gating
    //* ---------------------------------------------------------
    task test_enable_gating;
    begin
        $display("\n=== Testing Enable Gating ===");
        
        // Reset and load
        rst_n = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        load = 1;
        init_state = {8'b0, 8'hA5};
        @(posedge clk);
        load = 0;
        en = 0;  // Disable shifting
        #1;
        
        $display("State with en=0: 8'b%b", lfsr_out);
        
        // Wait a few cycles with en=0
        repeat(3) @(posedge clk);
        #1;
        
        $display("State after 3 cycles (en=0): 8'b%b", lfsr_out);
        
        // State should not have changed
        if (lfsr_out !== 8'hA5) begin
            $display("ERROR: State changed while enable was low!");
            $display("Expected 8'b10100101, Got 8'b%b", lfsr_out);
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("Enable gating OK: state unchanged when en=0");
        end
        
        // Now enable and verify it shifts
        en = 1;
        @(posedge clk);
        #1;
        
        if (lfsr_out === 8'hA5) begin
            $display("ERROR: State didn't change after enable!");
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("Enable OK: state changed to 8'b%b after en=1", lfsr_out);
        end
        
        en = 0;
        $display("=== Enable Gating Test Complete ===");
    end
    endtask

    //* ---------------------------------------------------------
    //* 9. TASK: init_golden_sequence
    //* ---------------------------------------------------------
    integer i;
    task init_golden_sequence;
        integer file_status;
    begin
        $display("\n=== Loading Golden Sequence from File ===");
        
        // Load binary file using $readmemb
        // File format: one 8-bit binary value per line
        file_status = $readmemb("golden_sequence.txt", golden_seq);
        
        if (file_status == 0) begin
            $display("ERROR: Failed to open golden_sequence.txt");
            $display("Make sure the file exists in the simulation directory");
            error_count = error_count + 1;
            test_pass = 0;
        end else begin
            $display("Successfully loaded golden sequence from file");
            $display("First 5 values for verification:");
            for (i = 0; i < 5; i = i + 1) begin
                $display("  Step %0d: 8'b%b", i, golden_seq[i]);
            end
        end
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
        
        // Load golden sequence from file (must be done first)
        init_golden_sequence();
        
        // Allow some time for initialization
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

    initial begin
        #100000;  // 100us timeout
        $display("\nERROR: Simulation timeout reached!");
        $display("The testbench may be stuck or running too long");
        $finish;
    end

endmodule