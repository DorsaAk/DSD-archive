/*

MODULE: seven_seg_decoder.v

DESCRIPTION:
    A combinational 7-segment display decoder.
    It Converts a 4‑bit binary value (0 to F) into the corresponding active‑low segment pattern
    for a common‑anode display.
    Since this is a simple mapping, the module is fully combinational.

MAPPING OF A COMMON-ANODE 7 SEG:
    seg[6] = a, seg[5] = b, seg[4] = c, seg[3] = d,
    seg[2] = e, seg[1] = f, seg[0] = g
    + Segment is ON when the corresponding bit is 0.

PORTS:
    INPUT: bin (4-bit unsigned binary)
    OUTPUT: seg (7-bit activelow)

ASSIGNMENT 
    Using correct Verilog practices. That is, approriate usage of block and non-blocking assignments and explicit sensitivity lists.

*/

module seven_seg_decoder (
    input wire [3:0] bin,   // the binary value to decode (which comes from the counter)
    output wire [6:0] seg   // 7-segment pattern, active-low
);

    assign seg =
        (bin == 4'd0)  ? 7'b100_0000 :   // 0
        (bin == 4'd1)  ? 7'b111_1001 :   // 1
        (bin == 4'd2)  ? 7'b010_0100 :   // 2
        (bin == 4'd3)  ? 7'b011_0000 :   // 3
        (bin == 4'd4)  ? 7'b001_1001 :   // 4
        (bin == 4'd5)  ? 7'b001_0010 :   // 5
        (bin == 4'd6)  ? 7'b000_0010 :   // 6
        (bin == 4'd7)  ? 7'b111_1000 :   // 7
        (bin == 4'd8)  ? 7'b000_0000 :   // 8
        (bin == 4'd9)  ? 7'b001_0000 :   // 9
        (bin == 4'd10) ? 7'b000_1000 :   // A
        (bin == 4'd11) ? 7'b000_0011 :   // b
        (bin == 4'd12) ? 7'b100_0110 :   // C
        (bin == 4'd13) ? 7'b010_0001 :   // d
        (bin == 4'd14) ? 7'b000_0110 :   // E
                        7'b000_1110 ;    // F

endmodule