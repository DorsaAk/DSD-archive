/*

reg_4bit.v models a single edge-triggered 4-bit storage element (register).

PORTS are:
    1. input: clk, rst_n, en, d
    2. output: q

PARAMETER:
    WIDTH (which is the constant 4 in this assignment, but it's better to parametrize for code reusability)

SPECS are:
    1. Asynch. active-low reset (rst_n)
    2. Active-high enable
    3. If enable is asserted, q <= d on posedge (new data is transferred to output)
    4. If enable = 0, output retains its value (Synchronus data hold)
    5. From 1 and 4: Thus, the module has asynch. reset and synch. write

X/Z BEHAVIOR:
    1. If rst_n is 'x' or 'z'. the reset is treated as inactive
    2. If d contains 'x' bits, they are propagated
    3. If 'en' is 'x', 

*/

module reg_4bit
#(
    parameter WIDTH = 4
)
(
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [WIDTH-1:0] d, // data input
    output reg [WIDTH-1:0] q  // data output
);


    always @(posedge clk or negedge rst_n) begin // asynchronous reset
        
        if(!rst_n) begin // active-low reset
            q <= {WIDTH{1'b0}}; // clear to zero on reset, non-blocking assignment in a sequential always block
        end

        else if (en) begin
            q <= d; // transfer data to q when enabled
        end

        // else?
        //      We don't need an else statement here. Since when there is no 'else' Verilog automatically latches the data and this is 
        //      exactly our desired behavior, as we want q to keep its current value.
        // However, we could write:
        // end else begin
        //      q <= q;
        // end

    end


endmodule