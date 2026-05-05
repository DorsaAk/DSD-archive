/*

decoder_2to_4.v converts a 2-bit address into a ont-hot write enable. *It uses addr to enable exactly one register for writing.*


PORTS are:
    1. input: en, addr
    2. output: y

PARAMETER:
    none needed
    
SPECS are:
    1. When en = 1: exactly one output is high (one af the bits in y, the one that corresponds to thyat address)
    2. When en = 0: all outputs are low

X/Z BEHAVIOR:
    When addr contains 'x' or 'z' bits, we must propagate uncertainty.

*/


module decoder_2to4
(
    input wire en,
    input wire [1 : 0] addr,
    output reg [3 : 0] y
);

    always @(*) begin
        if (!en) begin
            y = 4'b0000;  // none of the bits is hot in case the module is not enabled
        end else begin
            casez (addr)
                2'b00: y = 4'b0001;
                2'b01: y = 4'b0010;
                2'b10: y = 4'b0100;
                2'b11: y = 4'b1000;
                default: y = 4'bxxxx;  // if the address has x/z, propagate x
            endcase
        end
    end

endmodule

/*

WHY I USED CASEZ INSTEAD OF CASE:

    - In a standard case statement, all bits must match exactly (0, 1, x, z — everything compared with ===). If sel = 2'bx0, then case (sel) would not match 2'b00 because x ≠ 0.
    - CASEZ treats z (and ?) as wildcards (“don’t care”). So casez (2'bz0) matches 2'b00, 2'b10, 2'bx0, and 2'bz0 — any pattern where bit 0 is 0 and bit 1 is anything.  
    - (CASEX goes further and treats both x and z as wildcards, which is dangerous because it can silently swallow real X values during gate-level simulation.)

    - We wanted this behavior: if addr has any x or z bits, none of the explicit branches should match, and the default fires, driving y = 4'bxxxx.
    With a plain case, addr = 2'bx0 would already not match 2'b00 (since x !== 0 in case comparison), so the default would naturally catch it.


    - As I read, another way is using $isunknown as below, which catches any 'x' or 'y' bits in a bitwise value:
        else if ($isunknown(addr)) begin
            y = 4'bxxxx;
        end

*/