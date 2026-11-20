/*

tri_buf_4bit.v models a tri state buffer. Indeed, it its the tri-state buffer that allows us to use the data port BIDIRECTIONALLY.

PORTS are:
    1. input: in, en
    2. output: out

PARAMETER:
    WIDTH
    
SPECS are:
    1. Drives 'in' onto 'out' when 'en' is high. (Used when reading from the register file)
    2. Places output in high-impedance (Z) when 'en' is low (Used when writing to the register file)

X/Z BEHAVIOR:
    1. If en is 'x', the assignment `en ? in : 4'bz', produces 'x' on individual output bits; which correctly models the uncertainty of drive.
    2. If 'in' contains 'x', those are propagated in case of en = 1.

*/

module tri_buf_4bit
#(
    parameter WIDTH = 4
)
(
    input wire [WIDTH-1:0] in,
    input wire en,  // en = 1: drive and en = 0: High Impedance
    output wire [WIDTH-1:0] out  // this is the buffered output which is connected to inout bus
);

    // The tr-state operates purely combinationally, thus no clock is involved and all we need is a assign statement
    assign out = (en) ? in : {WIDTH{1'bz}};  //(the replication operator)

endmodule