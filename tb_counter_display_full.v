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
    function [6:0] expected_seg;
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



endmodule