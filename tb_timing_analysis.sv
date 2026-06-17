`timescale 1ns/1ps

module tb_timing_analysis;

    //* --------- parameters for easy manipulation during frequency sweeps ---------
    parameter real PERIOD = 10.0;
    parameter real SKEW = 0.0;


    //* --------- testbench wires and regs ---------
    reg in; // serial input sequence injected into the first stage (FF0)
    reg reset_n;  // asynch. active-low reset
    
    wire clk_master;  // the baseline reference clock, coming from the generator module
    wire clk_early;   // drives domain A (FF0, FF1)
    wire clk_late;    // drives domain B (FF2, FF3)
    wire [3:0] Q;     // output bus from the DUT


    //* --------- Instantiations ---------
    clk_gen #(
        .PERIOD(PERIOD),
        .SKEW(SKEW)
    ) u_clk_gen (
        .clk_master(clk_master),
        .clk_early(clk_early),
        .clk_late(clk_late)
    );

    shift_register u_shift_register (
        .clk_early(clk_early),
        .clk_late(clk_late),  
        .in(in),
        .reset_n(reset_n),     
        .Q(Q)                  
    );


    //* --------- Synchronous inp[ut sequence stimulus ---------
    //# Drives the required data stream: 1, 0, 1, 1, 0, 0, 1
    initial begin
        @(posedge reset_n);
        
        // Apply the test vector aligned strictly with the launching edge of clk_early
        @(posedge clk_early); in = 1'b1; 
        @(posedge clk_early); in = 1'b0;
        @(posedge clk_early); in = 1'b1; 
        @(posedge clk_early); in = 1'b1;
        @(posedge clk_early); in = 1'b0; 
        @(posedge clk_early); in = 1'b0; 
        @(posedge clk_early); in = 1'b1;
        
        // Keep the clock active for a few extra master periods to push data across the pipelines
        repeat(5) @(posedge clk_master);
        
        // Terminate the simulation
        $display("Simulation completed successfully.");
        $finish;
    end


    //* --------- Output Monitoring and Waveform Capture ---------
    initial begin
        // Continuously dump transition values to the simulation console window
        $monitor("Time = %6t ns | reset_n = %b | in = %b | Q = %b (Hex: %h)", 
                 $time, reset_n, in, Q, Q);
                 
        // Generate a VCD file for the waveforms
        $dumpfile("timing_analysis_output.vcd");
        $dumpvars(0, tb_timing_analysis); // Track every signal layer starting from this root scope
    end

endmodule