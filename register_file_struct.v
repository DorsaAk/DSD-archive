/*

The module register_file_struct.v models the 4-bit wide, 4-register deep register file in structural style.

BEING STRUCTURAL IMPLIES THAT:
    There are no always blocks describing behavior here.
    There are only assignment statements and instatntiations of the leaf cells we,ve written explicitly.

PORTS are:
    1. input: clk, rst_n, rd_wr, addr
    2. output: -
    3. inout: data

PARAMETER:
    -
    
SPECS are:
    1. WRITE PATH:
        data is drived (data) -> data is given as register inputs (d)
        How do we know which register to write to? exactly one register is enabled for writing via the one-hot encoding we wrote before
    2. READ PATH:
        Register output -> MUX input -> MUX gives output based on sel (= the 2-bit address) -> tri-state buffer -> data bus

X/Z BEHAVIOR:
    1. 

*/


module register_file_struct
(
    input  wire        clk,
    input  wire        rst_n,      // active-low asynchronous reset
    input  wire        rd_wr,     // 1 = read, 0 = write
    input  wire [1:0]  addr,       // 2-bit register address
    inout  wire [3:0]  data        // bidirectional 4-bit data bus
);

    // ------------------------- Internal wires -------------------------
    // ------------------------------------------------------------------
    wire [3:0] reg_en; // write enable from decoder to each register - Its values come from the decoder.
    wire tri_en; // tri-state buffer enable
    // Register outputs (q), which are given as inputs to the MUX
    wire [3:0] reg0_q;
    wire [3:0] reg1_q;
    wire [3:0] reg2_q;
    wire [3:0] reg3_q;
    //
    wire mux_out; // This is the output of the MUX whiich is given as input to the tri-state


    // ------------------------- Control Logic -------------------------
    // tri_en is asserted only during reads, as we have:
    //      rd_wr = 1 -> read -> drive the bus
    //      rd_wr = 0 -> write -> bus is High-Z
    assign tri_en = rd_wr;


    // ------------------------- Instantiations -------------------------
    // ------------------------------------------------------------------
    // An address decoder
    decoder_2to4 u_decoder (
        .en (!rd_wr),  //decoder enabled only when writing
        .addr (addr),
        .y (reg_en)  // one-hot: reg_en[i] = 1 → register i is written
    );

    // Four 4-bit registers (clocked together and independently enabled)
    reg_4bit #(.WIDTH(4)) ureg_0 (
        .clk(clk),
        .rst_n (rst_n),
        .en(reg_en[0]),
        .d(data),
        .q(reg0_q)
    );
    reg_4bit #(.WIDTH(4)) ureg_1 (
        .clk(clk),
        .rst_n (rst_n),
        .en(reg_en[1]),
        .d(data),
        .q(reg1_q)
    );
    reg_4bit #(.WIDTH(4)) ureg_2 (
        .clk(clk),
        .rst_n (rst_n),
        .en(reg_en[2]),
        .d(data),
        .q(reg2_q)
    );
    reg_4bit #(.WIDTH(4)) ureg_3 (
        .clk(clk),
        .rst_n (rst_n),
        .en(reg_en[3]),
        .d(data),
        .q(reg3_q)
    );

    // A 4-to-1 MUX : selects which register's output to read
    mux4_4bit #(.WIDTH(4)) u_MUX (
        .d0(reg0_q),
        .d1(reg1_q),
        .d2(reg2_q),
        .d3(reg3_q),
        .sel(addr),
        .y(mux_out)
    );

    // A tri-state buffer
    tri_buf_4bit #(.WIDTH(4)) u_TRI (
        .en(tri_en),
        .in(mux_out),
        .out(data) // this is connected to the inout port of the outermost module
    );

endmodule