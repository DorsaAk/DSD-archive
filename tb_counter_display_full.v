/*

MODULE: tb_counter_display_full.v

DESCRIPTION:
    Verifies every functional property of the module counter_siplay.v:
        1. Asynchronous reset and reliease
        2. Loading an external value
        3. Enabling / Disabling the counter
        4. Up / Down counting with wrap-around
        5. 7-seg output checked expected patterns
        6. Corner cases (load while counting, enable=0 then enable=1, etc.)

*/


`timescale 1ns/1ps

module tb_counter_display_full;

    // +-+-+-+-+-+-+-+-+- Defining Signals for DUT Connections +-+-+-+-+-+-+-+-+-
    reg clk;
    reg rst_n;
    reg up_down;
    reg en;
    reg load;
    reg [3:0] load_value;
    wire [3:0] count;
    wire [6:0] seg;

    // +-+-+-+-+-+-+-+-+- Function for Generating the Expected 7-seg Pattern +-+-+-+-+-+-+-+-+-
    function [6:0] expected_seg_f;
        input [3:0] val;
        begin
            case(val)
                4'd0:  expected_seg = 7'b100_0000;
                4'd1:  expected_seg = 7'b111_1001;
                4'd2:  expected_seg = 7'b010_0100;
                4'd3:  expected_seg = 7'b011_0000;
                4'd4:  expected_seg = 7'b001_1001;
                4'd5:  expected_seg = 7'b001_0010;
                4'd6:  expected_seg = 7'b000_0010;
                4'd7:  expected_seg = 7'b111_1000;
                4'd8:  expected_seg = 7'b000_0000;
                4'd9:  expected_seg = 7'b001_0000;
                4'd10: expected_seg = 7'b000_1000;
                4'd11: expected_seg = 7'b000_0011;
                4'd12: expected_seg = 7'b100_0110;
                4'd13: expected_seg = 7'b010_0001;
                4'd14: expected_seg = 7'b000_0110;
                4'd15: expected_seg = 7'b000_1110;
            endcase
        end
    endfunction

    // +-+-+-+-+-+-+-+-+- Instantiate DUT +-+-+-+-+-+-+-+-+-
    counter_display DUT(
        .clk(clk),
        .rst_n(rst_n),
        .up_down(up_down),
        .en(en),
        .load(load),
        .load_value(load_value),
        .count(count),
        .seg(seg)
    )

    // +-+-+-+-+-+-+-+-+- Clk Generation +-+-+-+-+-+-+-+-+-
    always #5 clk = ~clk;

    // +-+-+-+-+-+-+-+-+- Writing a Checker Task +-+-+-+-+-+-+-+-+-
    task check_output;
        input [3:0] expected_count;
        input [6:0] expected_seg_val;
        integer indicator = 0;
        begin
            #1; // wait a small time for propagation
            if(count !== expected_count) begin
                $display("ERROR at time %0t: Expected count = %d, Got = %d",
                         $time, expected_count, count);
                $stop;
                indicator = 1;
            end 
            if (seg !== expected_seg_val) begin
                $display("ERROR at time %0t: Expected seg = %b, Got = %b",
                         $time, expected_seg_val, seg);
                $stop;
                indicator = 1;
            end
            if(indicator == 1) begin
                $display("PASS  at time %0t: count = %d, seg = %b",
                         $time, count, seg);
            end
        end
    endtask



    // +-+-+-+-+-+-+-+-+- Main +-+-+-+-+-+-+-+-+-
    initial begin
        $display("=============================================");
        $display(" Full Testbench for counter_display");
        $display("=============================================");

        // Initialize
        clk = 0 ;   rst_n = 1;  up_down = 1;
        en = 0;     load = 0;   load_value = 4'd0;


        // ---------- Part 1: Asynchronous Reset ----------
        $display("\n--- Test 1: Asynchronous Reset ---");
        #3 rst_n = 0;
        #10 check_output(4'd0, expected_seg_f(0));
        rst_n = 1; // release reset
        #10 check_output(4'd0, expected_seg_f(0)); // the clear output must still hold after a reset


        // ---------- Part 2: Load Functionality ----------
        $display("\n\n--- Test 2: Loading An External Value ---")
        // Load value = 5
        load_value = 4'd5;
        load = 1;
        @(posedge clk);  // wait for the clock edge
        #1;
        check_output(4'd5, expected_seg_f(5));
        load = 0; // set load back to zero after waiting for #1

        // >>> Now giving Load Value while the counter is disabled <<<
        // In the case where the counter is enables, load_value still enters the counter if load = 1, eventhough it has no effect.
        load_value = 4'd1;
        load       = 1;
        @(posedge clk);
        #1;
        check_output(4'd0, expected_seg(0));
        load = 0;

        // >>> Load value = 3 (to prepare for up‑count test) <<<
        load_value = 4'd3;
        load       = 1;
        @(posedge clk);
        #1;
        check_output(4'd3, expected_seg(3));
        load = 0;


        // ---------- Part 3: Enable / Disable + Up Counting and Wrap-Around----------
        $display("\n\n--- Test 3: Enable = 0 (Hold) ---");
        en = 0;
        repeat(3) @(posedge clk);
        check_output(4'd3, expected_seg(3)); // must stay at 3

        $display("\n\n--- Test 4: Enable = 1 (Count Up) ---");
        en      = 1;
        up_down = 1;
        @(posedge clk); check_output(4'd4, expected_seg(4));
        @(posedge clk); check_output(4'd5, expected_seg(5));
        @(posedge clk); check_output(4'd6, expected_seg(6));
        @(posedge clk); check_output(4'd7, expected_seg(7));

        $display("\n--- Test 5: Up Wrap‑around ---");
        @(posedge clk); check_output(4'd0, expected_seg(0));
        @(posedge clk); check_output(4'd1, expected_seg(1));
        @(posedge clk); check_output(4'd2, expected_seg(2));


        // ---------- Part 4: Down Counting and Wrap-Around ----------
        $display("\n--- Test 6: Count Down ---");
        up_down = 0;
        @(posedge clk); check_output(4'd1, expected_seg(1));
        @(posedge clk); check_output(4'd0, expected_seg(0));

        $display("\n--- Test 7: Down Wrap‑around ---");
        @(posedge clk); check_output(4'd7, expected_seg(7));
        @(posedge clk); check_output(4'd6, expected_seg(6));
        @(posedge clk); check_output(4'd5, expected_seg(5));


        // ---------- Part 5: Load Overrides Enable ----------
        $display("\n--- Test 8: Load while enabled ---");
        en         = 1;
        load_value = 4'd2;
        load       = 1;
        @(posedge clk);
        #1;
        check_output(4'd2, expected_seg(2));
        load = 0;


        // ---------- Part 6: Direction Change ----------
        $display("\n--- Test 9: Direction change mid‑count ---");
        up_down = 1;
        @(posedge clk); check_output(4'd3, expected_seg(3));
        up_down = 0;
        @(posedge clk); check_output(4'd2, expected_seg(2));
        @(posedge clk); check_output(4'd1, expected_seg(1));


        // ---------- Part 7: Hold, Change Control Signals, Then Resume ----------
        $display("\n--- Test 10: Hold, change direction, resume ---");
        en = 0;
        repeat(2) @(posedge clk);
        check_output(4'd1, expected_seg(1)); // should still be 1
        up_down = 1;
        en = 1;
        @(posedge clk); check_output(4'd2, expected_seg(2));


        // ---------- Part 8: Load, Then Cound Down to Wrap ----------
        $display("\n--- Test 11: Load 0, count down to wrap ---");
        load_value = 4'd0;
        load       = 1;
        @(posedge clk);
        #1;
        check_output(4'd0, expected_seg(0));
        load  = 0;
        en    = 1;
        up_down = 0;
        @(posedge clk); check_output(4'd7, expected_seg(7));


        // ---------- Part 9: Reset mid-Operation ----------
        $display("\n--- Test 12: Asynchronous reset mid‑operation ---");
        #7 rst_n = 0;
        check_output(4'd0, expected_seg(0));
        rst_n = 1;


        $display("\n=============================================");
        $display(" ALL TESTS PASSED");
        $display("=============================================");
        $finish;

    end
    
endmodule