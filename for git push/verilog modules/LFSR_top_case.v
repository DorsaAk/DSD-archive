/*
    MODULE: LFSR_top_case.v
    PORTS:
        inputs: clk, rst_n, en, load, init_state
        outputs: random_out
    PARAMETERS:
        LFSR_TYPE (0, 1, or 2)
    DESCRIPTION:
        Alternative implementation using generate-case instead of generate-if.
        Functionally identical to LFSR_top_if but demonstrates the flexibility
        of Verilog's generate constructs for different coding styles.
*/


module lfsr_top_case #(
    parameter LFSR_TYPE = 0  // selects which LFSR configuration to use
) (
    input wire clk,
    input wire rst_n,        // active-low asynchronous reset
    input wire en,           // enable shifting
    input wire load,         // synchronous load
    input wire [15:0] init_state,  // maximum width (16 bits) for all configurations
    output wire [15:0] random_out // 16-bit output (upper bits zero-padded for smaller widths)
);

    //* ---------------------------------------------------------
    //* 1. Local parameters for each configuration
    //* ---------------------------------------------------------
    // Same tap definitions as generate-if version
    localparam [3:0]  TAPS_4  = 4'b1100;  // x⁴ + x³ + 1 → tap bits 3 and 2
    localparam [7:0]  TAPS_8  = 8'b10111000;  // x⁸ + x⁶ + x⁵ + x⁴ + 1
    localparam [15:0] TAPS_16 = 16'b1011010000000000;  // x¹⁶ + x¹⁴ + x¹³ + x¹¹ + 1
    
    
    //* ---------------------------------------------------------
    //* 2. Generate-case block for conditional instantiation
    //* ---------------------------------------------------------
    //# More on generate-case at the end of the code
    generate
        case (LFSR_TYPE)

            //* CASE 0: 4-bit LFSR
            0: begin : lfsr_type_0
                // Internal wire for 4-bit LFSR state
                wire [3:0] lfsr_state_4bit;
                // Instantiate 4-bit LFSR
                LFSR #(
                    .WIDTH(4),
                    .TAPS(TAPS_4)
                ) lfsr_inst_0 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .load(load),
                    .init_state(init_state[3:0]),  // only lower 4 bits used
                    .state(lfsr_state_4bit),
                    .random_out()  // unconnected
                );
                // Zero-pad upper 12 bits
                assign random_out = {12'b0, lfsr_state_4bit};
            end
            
            //* CASE 1: 8-bit LFSR
            1: begin : lfsr_type_1
                // Internal wire for 8-bit LFSR state
                wire [7:0] lfsr_state_8bit;
                // Instantiate 8-bit LFSR
                LFSR #(
                    .WIDTH(8),
                    .TAPS(TAPS_8)
                ) lfsr_inst_1 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .load(load),
                    .init_state(init_state[7:0]),  // only lower 8 bits used
                    .state(lfsr_state_8bit),
                    .random_out()  // unconnected
                );
                // Zero-pad upper 8 bits
                assign random_out = {8'b0, lfsr_state_8bit};
            end
            
            //* CASE 2: 16-bit LFSR
            2: begin : lfsr_type_2
                // Internal wire for 16-bit LFSR state
                wire [15:0] lfsr_state_16bit;
                // Instantiate 16-bit LFSR
                LFSR #(
                    .WIDTH(16),
                    .TAPS(TAPS_16)
                ) lfsr_inst_2 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .load(load),
                    .init_state(init_state),  // all 16 bits used
                    .state(lfsr_state_16bit),
                    .random_out()  // unconnected
                );
                // No zero-padding needed
                assign random_out = lfsr_state_16bit;
            end
            
            //* DEFAULT: Invalid LFSR_TYPE
            default: begin : lfsr_type_invalid
                // Handle any unexpected LFSR_TYPE values
                assign random_out = 16'b0;
            end
        endcase
    endgenerate

endmodule


//# About generate-case:
/*
    generate-case is also evaluated at elaboration time, just like
    generate-if. It produces exactly the same hardware as generate-if
    for mutually exclusive conditions.
    
    The main difference is stylistic: case statements are more readable
    when you have multiple discrete values to select from, especially
    when the values are named or enumerated.
    
    The synthesizer will create ONLY the hardware for the matching case.
    All other cases are completely eliminated during elaboration.
*/