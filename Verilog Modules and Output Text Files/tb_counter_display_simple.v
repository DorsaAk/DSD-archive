/*

MODULE: tb_counter_display_simple.V

DESCRIPTION:
    A simpler testbench, only to highlight the difference between codes of Part A and Part B.
    Part A: Correct Verilog Practices
    Part B: Replacing all the NB assginments with B assignments in the sequential always block

OUTLITNE:
    (1) Reset
    (2) Load = 5
    (3) Count Up Twice
    (4) Count Down Once
    Each step is separated by a single clock edge.

*/


`timescale 1ns / 1ps

module tb_counter_display_simple;

    // +-+-+-+-+-+-+-+-+- DUT Connections +-+-+-+-+-+-+-+-+-
    reg         clk;
    reg         rst_n;
    reg         up_down;
    reg         en;
    reg         load;
    reg  [3:0]  load_value;
    wire [3:0]  count;
    wire [6:0]  seg;

    // +-+-+-+-+-+-+-+-+- Instantiation +-+-+-+-+-+-+-+-+-
    counter_display DUT (
        .clk        (clk),
        .rst_n      (rst_n),
        .up_down    (up_down),
        .en         (en),
        .load       (load),
        .load_value (load_value),
        .count      (count),
        .seg        (seg)
    );

    // +-+-+-+-+-+-+-+-+- Clk Generation and Monitoring +-+-+-+-+-+-+-+-+-
    always #5 clk = ~clk;
    always @(posedge clk) begin
        $display("[t=%0t] rst_n=%b up_down=%b en=%b load=%b load_value=%d  →  count=%d  seg=%b",
                 $time, rst_n, up_down, en, load, load_value, count, seg);
    end


    // +-+-+-+-+-+-+-+-+- Testing in the Sequence Specified +-+-+-+-+-+-+-+-+-
    initial begin
        $display("=============================================");
        $display(" Simple Testbench Sequence");
        $display("=============================================");

        // Initial values
        clk        = 0;
        rst_n      = 1;
        up_down    = 1;
        en         = 0;
        load       = 0;
        load_value = 4'd0;

        // Step 1: Reset
        rst_n = 0;
        #20;
        rst_n = 1;
        @(posedge clk);

        // Step 2: Load = 5
        load_value = 4'd5;
        load       = 1;
        @(posedge clk);
        load       = 0;

        // Step 3: Count up twice
        en      = 1;
        up_down = 1;
        @(posedge clk);
        @(posedge clk);

        // Step 4: Count down once
        up_down = 0;
        @(posedge clk);

        // Done
        #20;
        $display("=============================================");
        $display(" Sequence complete.");
        $display("=============================================");
        $finish;
    end

endmodule