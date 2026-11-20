// File: tb_counter_mixed.v
`timescale 1ns / 1ps

module tb_counter_mixed;

    reg clk, rst_n;
    wire [3:0] count1, count2;

    // Instantiate BOTH versions so we can compare in one waveform
    counter_mixed_case1  DUT1 (.clk(clk), .rst_n(rst_n), .count(count1));
    counter_mixed_case2  DUT2 (.clk(clk), .rst_n(rst_n), .count(count2));

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;

        $dumpfile("partD_wave.vcd");
        $dumpvars(0, tb_counter_mixed);

        $monitor("[t=%0t] rst_n=%b  count1=%d  count2=%d",
                 $time, rst_n, count1, count2);

        // Assert reset for 2 clock cycles
        #20 rst_n = 1;

        // Let it run for 20 clock cycles and observe
        #200;

        $display("\n=============================================");
        $display("Observations:");
        $display(" count1 increments every clock (looks OK but is fragile)");
        $display(" count2 increments every OTHER clock (order changed, behaviour changed!)");
        $display("=============================================");
        $finish;
    end

endmodule
