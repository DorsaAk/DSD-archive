module shift_register (
    input clk_early, // for FF0, FF1
    input clk_late, // for FF2, FF3
    input in,
    input reset_n,
    output [3:0] Q
);
    wire q0, q1, q2, q3;
    wire and_out, xor_out;
    dff_timing ff0 (.clk(clk_early), .d(in), .reset_n(reset_n), .q(q0));
    dff_timing ff1 (.clk(clk_early), .d(q0), .reset_n(reset_n), .q(q1));
    dff_timing ff2 (.clk(clk_late), .d(and_out), .reset_n(reset_n), .q(q2));
    dff_timing ff3 (.clk(clk_late), .d(xor_out), .reset_n(reset_n), .q(q3));
    and2 #(.tPD(0.6)) gate_and (.out(and_out), .a(q1), .b(q0));
    xor2 #(.tPD(0.6)) gate_xor (.out(xor_out), .a(q2), .b(q0));
    assign Q = {q3, q2, q1, q0};
endmodule