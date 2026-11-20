`timescale 1ns/1ps

module dff_timing (
    input clk, d, reset_n,
    output q
);
    parameter tCQ = 0.8, tSU = 0.5, tH = 0.4;
    reg q_int;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            q_int <= 1'b0;
        else
            q_int <= d;
    end
    assign #(tCQ) q = q_int; // to model inertial delay
    specify
        $setup(d, posedge clk, tSU);
        $hold(posedge clk, d, tH);
    endspecify
endmodule

