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

    always @(posedge clk or negedge rst_n) begin  // explicit sensitivity list, sequential always block, asynch. reset
        // ------Since the always block is sequential, all the assignments are non-blocking. -------
        // asynchronous, active-low reset
        if (!rst_n) begin
            count <= 4'b0000;
        end

        // synchronous part
        else begin
            // **** Load (possible external value to drive the counter) ****
            if(load) begin
                count <= load_value;
            end
            // If the counter is disabled, the loadvalue still sits in `count`, but there is not output.
            
            // **** Enabled ****
            else if (en) begin
                // direction: up
                if(up_down) begin
                    // wrap from 7 back to 0
                    if (count >= 4'd7)  // I could have written count == 4'd7
                        count <= 4'd0;
                    else
                        count <= count + 1;
                end
                // direction: down
                else if(!up_down) begin
                    // wrap from 0 back to 7
                    if (count <= 4'd0) // Again this could've been: count == 4'd0
                        count <= 4'd7;
                    else
                        count <= count - 1;
                end
            end
            // **** Disabled ****
            /* Here we can write sth like:
            else begin
                count <= count
            end
            But as we know that in cases where there is no else statement, Verilog automatically assumes a latch
            for holding the value the same as it was, there is no need for such statement
            */
        end
    end
endmodule