/*

MODULE: rx_fsm.sv
    This is the receiver side in the serial communication we model.

PORTS:
    Parameter: DATA_WIDTH
    In: clk, reset_n, serial_n
    Out: data_out, data_valid
    
SPECS & REQUIREMENTS:
    1. The receiver continuously monitors serial_in for a start bit (0).
    2. The procedure:
        When a start bit is detected (falling edge while in IDLE), the FSM moves to a START 
        state (one clock cycle), then samples the four data bits (one bit per state, LSB first), 
        then checks the stop bit (must be 1).
    3. At STOP (if the stop bit is correct):
        The FSM goes to a DONE state where data_valid is asserted for one cycle; otherwise it returns 
        to IDLE without asserting data_valid.\
    4. data_valid is assigned combinationally, 1 only in the DONE state and 0 otherwise.
    5. Here, we assume that the testbench samples data_out only when data_valid = 1 (and later, we will
    implement the same behavior in the testbench.)
    6. The start bit detection must be edge-sensitive -> this is why we need the internal register serial_in_prev

*/


module rx_fsm #(
    parameter DATA_WIDTH = 4
) (
    input  logic clk,
    input  logic reset_n,
    input  logic serial_in,
    output logic signed [DATA_WIDTH-1:0] data_out,
    output logic data_valid
);

    // State Encoding
    typedef enum logic [2:0] {
        IDLE  = 3'b000,
        START = 3'b001,
        BIT0  = 3'b010,
        BIT1  = 3'b011,
        BIT2  = 3'b100,
        BIT3  = 3'b101,
        STOP  = 3'b110,
        DONE  = 3'b111
    } state_t;

    state_t current_state, next_state;

    


endmodule