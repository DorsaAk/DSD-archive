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
    7. The received data bits must be assembled into a shift register

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

    // Internal registers
    logic serial_in_prev; // The detection of the start bit must be edge-sensitive and we need this for updating the values in each cycle.
    logic  signed [DATA_WIDTH-1:0] shift_reg; // The received data bits must be assembled into a shift register.


    //* =========================================================================
    //* BLOCK #1: Sequential Logic: State Register
    //* =========================================================================
    //# This is where the next_state is assigned to the current_state at each clock edge
    always_ff @(posedge clk or negedge reset_n) begin // asynch reset
        if (reset_n == 0) //active-low reset
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //* =========================================================================
    //* BLOCK #2: Combinational Logic: Next State Logic
    //* =========================================================================
    //# This is where we determine what the next_state will be based on the current_state
    always_comb begin
        case(current_state)
            IDLE: begin
                if (serial_in_prev == 1'b1 && serial_in == 1'b0) // Detect falling edge on serial_in (Start Bit)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            START: next_state = BIT0;
            BIT0:  next_state = BIT1;
            BIT1:  next_state = BIT2;
            BIT2:  next_state = BIT3;
            BIT3:  next_state = STOP;
            STOP: begin
                if(serial_in == 1'b1) // checking if the stop bit is valid (must be 1)
                    next_state = DONE;
                else
                    next_state = IDLE; // framing error, invalid stop -> drop the packet
            end
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    //@ =========================================================================
    //@ Determining data_valid combinationally
    //@ =========================================================================
    always_comb begin
        if (current_state == DONE)
            data_valid = 1'b1;
        else
            data_valid = 1'b0;
    end

    //* =========================================================================
    //* BLOCK #3: Sequential Logic: Shift Register & Edge Detection
    //* =========================================================================
    //# Here is where we deal with the output data_out (based on a Moore framework) and the shift register
    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 0) begin
            serial_in_prev <= 1'b1; // Line idle state is high
            shift_reg      <= '0;
            data_out       <= '0;
        end else begin
            // Track the previous previous value of serial_in for falling edge detection
            // According to the code in BLOCK #2, in case a falling edge is detectged (serial_in_prev == 1'b1 && serial_in == 1'b0),
            // the FSM changes its state from IDLE to START
            serial_in_prev <= serial_in;

            // shift the data bits, LBS first (only in case the current state is one of BIT0, BIT1, BIT2 or BIT3)
            if(current_state == BIT0 || current_state == BIT1 ||
               current_state == BIT2 || current_state == BIT3) begin
                // the bits of serial_in enter one by one and shift the content of shift_reg 
                // Because both TX and RX are Moore FSMs on the same clock, RX is lagging behind TX by exactly one cycle.
                // This is why I use serial_in_prev and not serial_in
                shift_reg <= {serial_in_prev, shift_reg[DATA_WIDTH-1 : 1]};  
            end

            // Output the accumulated word only when frame is successfully received (STOP is valid and thus the state DONE occurs)
            if(current_state == DONE) begin
                data_out <= shift_reg;
            end
        end
    end

endmodule