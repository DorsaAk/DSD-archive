module and2 (out, a, b);
    parameter tPD = 0.6;
    output out;
    input a, b;
    assign #(tPD) out = a & b;
endmodule

module xor2 (out, a, b);
    parameter tPD = 0.6;
    output out;
    input a, b;
    assign #(tPD) out = a ^ b;
endmodule

module my_buf (out, in);
    parameter tPD = 0.3;
    output out;
    input in;
    assign #(tPD) out = in;
endmodule

