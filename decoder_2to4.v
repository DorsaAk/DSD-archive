/*

decoder_2to4.v converts a 2-bit address into a ont-hot write enable. In practice, this is the module that maps the addresses into the actual registers they point to.

PORTS are:
    1. input: en, addr
    2. output: y

PARAMETER:
    WIDTH
    
SPECS are:
    1. When en = 1: exactly one output is high (one af the bits in y, the one that corresponds to thyat address)
    2. When en = 0: all outputs are low

X/Z BEHAVIOR:
    When addr contains 'x' or 'z' bits, we must propagate uncertainty.

*/


module decoder_2to_4
#(
    parameter WIDTH = 4;
)
(
    input wire en,
    input wire [($clog2(WIDTH) - 1) : 0] addr,
    output reg [(WIDTH - 1) : 0] y
);

    always @(*) begin
        if (!en) begin
            y = 4'b0000;  // none of the bits is hot in case the module is not enabled
        end else begin
            casez (addr)
                2'b00: y = 4-b0001;
                2'b01: y = 4'b0010;
                2'b10: y = 4'b0100;
                2'b11: y = 4'b1000;
                default: y = 4'bxxxx;  // if the address has x/z, propagate x
            endcase
        end
    end

endmodule