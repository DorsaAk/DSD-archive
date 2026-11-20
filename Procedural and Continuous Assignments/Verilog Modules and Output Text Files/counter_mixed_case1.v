// File: counter_mixed_case1.v
// Blocking assignment FIRST, non‑blocking assignment SECOND.
// This ordering accidentally gives the right count, but it is NOT safe.

module counter_mixed_case1 (
    input  wire       clk,
    input  wire       rst_n,
    output wire [3:0] count
);

    reg  [3:0] count_reg;
    reg  [3:0] next_count;       // internal “intermediate” register

    assign count = count_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_reg  <= 4'd0;
            next_count <= 4'd0;   // also reset it, otherwise X+1 = X
        end else begin
            next_count = count_reg + 1;   // BLOCKING   – uses OLD count_reg
            count_reg <= next_count;      // NON‑BLOCKING – schedules the update
        end
    end

endmodule
