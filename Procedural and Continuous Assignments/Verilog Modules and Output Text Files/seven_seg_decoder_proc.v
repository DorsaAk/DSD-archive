/*

MODULE: seven_seg_decoder_proc.v

DESCRIPTION:
    From seven_seg_decoder_proc_BAD.v, correct procedural version using always @(*).

MAPPING OF A COMMON-ANODE 7 SEG:
    seg[6] = a, seg[5] = b, seg[4] = c, seg[3] = d,
    seg[2] = e, seg[1] = f, seg[0] = g
    + Segment is ON when the corresponding bit is 0.

PORTS:
    INPUT: bin (4-bit unsigned binary)
    OUTPUT: seg (7-bit activelow)

*/

module seven_seg_decoder_proc (
    input wire [3:0] bin,   // the binary value to decode (which comes from the counter)
    output reg [6:0] seg   // 7-segment pattern, active-low
);

    always @(*) begin
        case(bin)
            4'd0:    seg = 7'b1000000;  // 0
            4'd1:    seg = 7'b1111001;  // 1
            4'd2:    seg = 7'b0100100;  // 2
            4'd3:    seg = 7'b0110000;  // 3
            4'd4:    seg = 7'b0011001;  // 4
            4'd5:    seg = 7'b0010010;  // 5
            4'd6:    seg = 7'b0000010;  // 6
            4'd7:    seg = 7'b1111000;  // 7
            4'd8:    seg = 7'b0000000;  // 8
            4'd9:    seg = 7'b0010000;  // 9
            4'd10:   seg = 7'b0001000;  // A
            4'd11:   seg = 7'b0000011;  // b
            4'd12:   seg = 7'b1000110;  // C
            4'd13:   seg = 7'b0100001;  // d
            4'd14:   seg = 7'b0000110;  // E
            4'd15:   seg = 7'b0001110;  // F
            default: seg = 7'b1111111;
        endcase
    end

endmodule