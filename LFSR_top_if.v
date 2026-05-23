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
    //# More on generate if at the end of the code
    generate
        //* CONFIGURATION 0: 4-bit LFSR
        if (LFSR_TYPE == 0) begin: lfsr_config_0
            // Internal wire to capture the 4-bit LFSR state
            wire lfsr_state_4bit;
            // Instantiate 4-bit LFSR
            // Only the lower 4 bits of init_state are used
            LFSR #(
                .WIDTH(4),
                .TAPS(TAPS_4)
            ) lfsr_4bit_inst (
                .clk(clk),
                .rst_n(rst_n),
                .en(en),
                .load(load),
                .init_state(init_state[3:0]), // slice the lower 4 bits of init_state
                .state(lfsr_state_4bit),
                .random_out() // left unconnected as I used state instead
            );
            // Zero-pad upper 12 bits as required by specification
            // Concatenation: {12 bits of 0, 4 bits of LFSR state}
            assign random_out = {12'b0, lfsr_state_4bit};
        end

        //* CONFIGURATION 1: 8-bit LFSR
        else if (LFSR_TYPE == 1) begin: lfsr_config_1
            // Internal wire to capture the 8-bit LFSR state
            wire [7:0] lfsr_state_8bit;
            // Instantiate 8-bit LFSR
            // Only the lower 8 bits of init_state are used
            LFSR #(
                .WIDTH(8),
                .TAPS(TAPS_8)
            ) lfsr_8bit_inst (
                .clk(clk),
                .rst_n(rst_n),
                .en(en),
                .load(load),
                .init_state(init_state[7:0]),  // slice lower 8 bits
                .state(lfsr_state_8bit),
                .random_out()  // left unconnected
            );
            // Zero-pad upper 8 bits
            assign random_out = {8'b0, lfsr_state_8bit};
        end

        //* CONFUIGURATION 2: 16-bit LFSR
        else if (LFSR_TYPE == 2) begin: lfsr_config_2
            // Internal wire to capture the 16-bit LFSR state
            wire [15:0] lfsr_state_16bit;
            // Instantiate 16-bit LFSR
            // All 16 bits of init_state are used
            LFSR #(
                .WIDTH(16),
                .TAPS(TAPS_16)
            ) lfsr_16bit_inst (
                .clk(clk),
                .rst_n(rst_n),
                .en(en),
                .load(load),
                .init_state(init_state),  // full 16 bits used
                .state(lfsr_state_16bit),
                .random_out()  // left unconnected
            );
            // No zero-padding needed - all 16 bits are valid
            assign random_out = lfsr_state_16bit;
        end

        //* Error handling for invalid LFSR_TYPE values
        else begin : lfsr_config_invalid
            // For any value other than 0, 1, or 2
            // Output all zeros to indicate invalid configuration
            assign random_out = 16'b0;
        end
    endgenerate
    
endmodule

//# About generate-if:
/*
    generate-if is evaluated at compile/elaboration time, NOT at runtime.
    This means the hardware for only ONE of the three LFSRs will be 
    synthesized, saving area and power. If we used a regular if-else
    inside an always block, ALL three LFSRs would need to exist in hardware
    and a multiplexer would select between them, which is much more expensive!

    Named blocks (lfsr_config_0, lfsr_config_1, etc.) create unique
    hierarchical scopes that prevent naming conflicts and help with
    debugging in the synthesized design.

*/