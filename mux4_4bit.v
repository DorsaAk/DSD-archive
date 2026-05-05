/*

mux4_4bit.v selects one of the 4 registers and  *uses addr (as sel) to choose which register’s output to route to the data bus for reading*.

PORTS are:
    1. input: d0, d1, d2, d3 (the data inputs), sel
    2. output: y

PARAMETER:
    WIDTH
    
SPECS are:
    1. sel is the 2-bit adress based on which we choose the data of one of the registers to transfer to y

X/Z BEHAVIOR:
    1. If sel contains unknown bits, we must propagate x

*/


module mux4_4bit
#(
    parameter WIDTH = 4
)
(
    input wire [WIDTH-1:0] d0, d1, d2, d3,
    input wire [1:0] sel,
    output reg [WIDTH-1:0] y
);
    
    always @(*) begin
        // Again, this module is purely combinational, so we use always @(*). We could've used conditional assignments, but they would've gotten nested and messy.
        casez(sel)
            2'b00:   y = d0;  // blocking assignments in a combinational always block
            2'b01:   y = d1;
            2'b10:   y = d2;
            2'b11:   y = d3;
            default: y = {WIDTH{1'bx}}; // the replication operator
        endcase

    end

endmodule