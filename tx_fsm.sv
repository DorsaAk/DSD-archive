/*

MODULE: tx_fsm.sv
    This is the transmitter module in the serial communication we model

PORTS:
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

*/


module tx_fsm #(parameter DATA_WIDTH = 4) (
    input logic clk,
    input logic reset_n,
    input logic start, // pulse to start transmission
    input logic signed [DATA_WIDTH-1:0] data_in, // parallel signed data
    output logic serial_out
);

//* FSM states
typedef enum logic [2:0]{
    IDLE,
    START,
    BIT0,
    BIT1,
    BIT2,
    BIT3,
    STOP
} state_t;




endmodule