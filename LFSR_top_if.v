/*
    MODULE: LFSR_top_if.v
    PORTS:
        inputs: clk, rst_n, en, load, init_state
        outputs: random_out
    PARAMETERS:
        LFSR_TYPE (0, 1, or 2)
    DESCRIPTION:
        Top-level module that instantiates different LFSR configurations
        using generate-if statements. Supports 4-bit, 8-bit, and 16-bit LFSRs.
*/

module LFSR_top_if #(
    parameter LFSR_TYPE = 0
) (
    input wire clk,
    input wire rst_n,  // active-low asynchronous reset
    input wire en,  // enable shifting
    input wire load,  // synchronous load
    input wire [15:0] init_state,  // max width (16 bits) for all configurations
    output wire [15:0] random_out // 16-bit output (upper bits zero-padded for smaller width)
);

    //* ---------------------------------------------------------
    //* 1. Local parameters for each configuration
    //* ---------------------------------------------------------
    // These define the tap masks for maximal-length sequences
    // Bit positions: [3]=x⁴, [2]=x³, [1]=x², [0]=x¹, ...
    // The constant term "1" is implicit and doesn't need a tap
    localparam [3:0] TAPS_4  = 4'b1100;  // x⁴ + x³ + 1 → tap bits 3 and 2
    localparam [7:0] TAPS_8 = 8'b10111000;  // x⁸ + x⁶ + x⁵ + x⁴ + 1
    localparam [15:0] TAPS_16 = 16'b1011010000000000;  // x¹⁶ + x¹⁴ + x¹³ + x¹¹ + 1
    

    //* ---------------------------------------------------------
    //* 2. Generate-case block for conditional instantiation
    //* ---------------------------------------------------------
    

endmodule

