/*
    MODULE: tb_seven_seg_proc
    
    DESCRIPTION: A simple testbanch to showcase the difference between thw two modules in part C
*/

`timescale 1ns / 1ps

module tb_seven_seg_proc;

    reg  [3:0] bin;
    wire [6:0] seg_bad;
    wire [6:0] seg_good;

    // Instantiate BOTH versions so we can compare in one waveform
    seven_seg_decoder_proc_BAD  DUT_BAD  (.bin(bin), .seg(seg_bad));
    seven_seg_decoder_proc      DUT_GOOD (.bin(bin), .seg(seg_good));

    initial begin
        $dumpfile("partC_wave.vcd");
        $dumpvars(0, tb_seven_seg_proc);

        $monitor("[t=%0t] bin=%d  seg_bad=%b  seg_good=%b",
                 $time, bin, seg_bad, seg_good);

        bin = 4'd0;
        #10 bin = 4'd5;
        #10 bin = 4'd10;
        #10 bin = 4'd15;
        #10 bin = 4'd3;
        #20 $finish;
    end

endmodule
