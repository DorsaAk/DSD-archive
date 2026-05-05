/*

The module register_file_rtl.v models the 4-bit wide, 4-register deep register file in
RTL (Register Transfer Level, aka Behavioral) style.

BEING BEHAVIORAL IMPLIES THAT:
    - We describe what the circuit does, not how it is wired gate-by-gate.
    - We only use high-level procedural constructs such as always blocks, if-else statements, cases and arrays of registers, and the synthesis tool figures it out. 

PORTS are:
    input: clk, rst_n, rd_wr, addr
    output: -
    inout: data

PARAMETER:
    -
    
SPECS are:
    WRITE:
        When rd_wrn = 0 and posedge clk, the addressed register captures whatever is on data. This replaces the decoder + individual register enables.
    READ:
        read_data is a combinational select: regs[addr]. If addr has any x/z bit, $isunknown forces read_data = 4'bxxxx.
    TRI STATE:
        The continuous assignment assign data = (rd_wrn) ? read_data : 4'bzzzz; exactly replaces the tri_buf_4bit instance. When rd_wrn = 0, data = Z — the testbench drives the bus.

X/Z BEHAVIOR:
    1. If the address is invalid (contains x or z):
        1.1. read_data has the value 4'bxxxx
        1.2. data bus has 4'bxxxx, as the tri-state buffer passes x through
    2. If a write operation is in process:
        2.1. The data bus gets 4'bzzzz from the regfile side, as the tri-state buffer/continuous assignment is disabled and the register file releases the bus.

    THUS:
        1. Any unknown on the address lines propagates 4'bxxxx to the data bus during a read.
        2. The register file never drives the bus during a write. The bus is Hi‑Z from the design under test’s perspective,
        and the testbench is responsible for placing data there. If the testbench also releases the bus during a write, data
        floats at 4'bzzzz and the targeted register captures Z — which is correct but not useful for testing.
        3. Also, during a reset, the storage is cleaned to zero and the bus is not driven. The testbench also, must not drive data during reset.
*/

module register_file_rtl
(
    input wire clk, 
    input wire rst_n,
    input wire rd_wr,
    input wire [1:0] addr,
    inout wire [3:0] data
);

    // ------------------------- Register File Storage -------------------------
    reg [3:0] regs [0:3];  // 4-bit register: regs[0] to regs[3]

    // ------------------------- Synchronous Write -------------------------


    // ------------------------- Combinational Read -------------------------

    

endmodule