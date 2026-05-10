/*

MODULE: up_down_counter.v

DESCRIPTION:
    4-bit up/down counter with synchronous load, enable, and asynchronous active-low reset.
    Counting is restricted to the [0,...,7] range; wrap-round occurs at the boundaries (0 when
    counting downwards and 7 when counting upwards).

PORTS:
    INPUT: clk, rst_n, up_down, en, load, load_value
    OUTPUT: count

ASSIGNMENT 
    Using correct Verilog practices. That is, approriate usage of block and non-blocking assignments and explicit sensitivity lists.

*/


module up_down_counter(
    input wire clk,
    input wire rst_n, // asynch active-low reset
    input wire up_down,  // 1 = count up, 0 = count down
    input wire en,  // 1 = counter is enabled
    input wire load,    // if the counter needs to be driven by an external value
    input wire [3:0] load_value, // value to be loaded
    output reg [3:0] count  // current counter value
);

    always @(posedge clkj or negedge rst_n) begin  // explicit sensitivity list, sequential always block, asynch. reset
        
    end

endmodule