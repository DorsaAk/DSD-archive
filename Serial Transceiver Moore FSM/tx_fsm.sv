/*

MODULE: tx_fsm.sv
    This is the transmitter side in the serial communication we model

PORTS:
    Parameter: DATA_WIDTH
    In: clk, reset_n, start, data_in, serial_out
    Out: serial_out

SPECS & REQUIREMENTS:
    1. On reset_n:
        reset_n is an active-low asynch. reset
        reset_n = 0 -> FSM goes to IDLE and serial_out is forced to 1 (idel line)
    2. In IDLE, if start = 1, the transmission begins; otherwise stay in idle
    3. At START, serial_out = 0 and at STOP and IDLE, serial_out = 1
    4. Transmission sequence:
       START -> BIT0 (LSB) -> BIT1 -> BIT2 -> BIT3(MSB) -> STOP -> IDLE
    5. While trasmitting the start input is ignored (the connection is non-resumeable).
    6. The FSM is a Moore one and the seria_out signal is a combination of the current state only.
    7. Each state lasts exactly one clock cycle

*/


module tx_fsm #(
    parameter DATA_WIDTH = 4
) (
    input logic clk,
    input logic reset_n,
    input logic start, // pulse to start transmission
    input logic signed [DATA_WIDTH-1:0] data_in, // parallel signed data
    output logic serial_out
);

    //* FSM states, definec using `typedef enum`
    typedef enum logic [2:0]{
        IDLE  = 3'b000,
        START = 3'b001,
        BIT0  = 3'b010,
        BIT1  = 3'b011,
        BIT2  = 3'b100,
        BIT3  = 3'b101,
        STOP  = 3'b110
    } state_t;

    state_t current_state, next_state; // defining current_state and next_state as states we just specified the different cases of

    //# Register to lock in the data so  it doesn't change mid-transmission
    logic [DATA_WIDTH-1:0] data_reg;
    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 0) begin
            data_reg <= 0;
        end else if (current_state == IDLE && start) begin // if we are right at our starting point...
            data_reg <= data_in; // register the incoming data_in into data_reg
        end
    end

    //* =========================================================================
    //* BLOCK #1: Sequential State Register
    //* =========================================================================
    //# This is where the next_state is assigned to the current_state at each clock edge
    always_ff @( posedge clk or negedge reset_n ) begin // asynchronous reset
        if(reset_n == 0) begin // active-low reset
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    //* =========================================================================
    //* BLOCK #2: Combinational Next-State Logic
    //* =========================================================================
    //# This is where we determine what the next_state will be based on the current_state
    always_comb begin
        case (current_state)
            IDLE: begin // when in IDLE, wait for the start pulse
                if(start)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            START:  next_state = BIT0;
            BIT0:   next_state = BIT1;
            BIT1:   next_state = BIT2;
            BIT2:   next_state = BIT3;
            BIT3:   next_state = STOP;
            STOP:   next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    //* =========================================================================
    //* BLOCK #3: Combinational Output Logic
    //* =========================================================================
    //# This is where we determine the output signal. Since we aim for a Moore FSM, the output depends
    //# solely on the current state.
    always_comb begin
        case (current_state)
            IDLE:  serial_out = 1'b1;  // the output is forced to 1 in idle state
            START: serial_out = 1'b0;  // the START bit is 0
            BIT0:  serial_out = data_reg[0];  // LSB first
            BIT1:  serial_out = data_reg[1];
            BIT2:  serial_out = data_reg[2];
            BIT3:  serial_out = data_reg[3];  // MSB last
            STOP:  serial_out = 1'b1;  // the STOP bit is 1
            default: serial_out = 1'b1;
        endcase
    end

endmodule