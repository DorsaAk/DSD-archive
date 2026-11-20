/*

MODULE: counter_display.v

DESCRIPTION:
    The top-level wrapper that connects a 4-bit up/down counter to a 7-segment decoder.

PORTS:
    INPUT: clk, rst_n, up_down, en, load, load_value
    OUTPUT: count, seg

INSTANTIATED SUB-MODULES:
    up_down_counter (sequential)
    seven_seg_decoder (combinational)

*/

module counter_display(
    input wire clk,
    input wire rst_n, // active-low, asynchronous reset
    input wire up_down, // 1 = count up, 0 = count down
    input wire en,  // 1 = the counter is enabled (if disabled, the current value is held as is)
    input wire load, // 1 = the counter needs to be driven by an external value
    input wire [3:0] load_value, // value to be loaded
    output wire [3:0] count, // the output of the counter, exposed merely for simpler verification
    output wire [6:0] seg // generated 7-segment pattern (common-anode -> active-low)
);

    wire [3:0] count_val; // an intermediary signal between the modules, identically mapped to `counter`

    // Instance #1: up_down_counter
    up_down_counter U_COUNTER (
            .clk        (clk),
            .rst_n      (rst_n),
            .up_down    (up_down),
            .en         (en),
            .load       (load),
            .load_value (load_value),
            .count      (count_val)
    );

    // Instance #2: seven_seg_decoder
    seven_seg_decoder U_DECODER (
            .bin (count_val),
            .seg (seg)
    );

    assign count = count_val;

endmodule