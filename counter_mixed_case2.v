// File: counter_mixed_case2.v
// Non‑blocking assignment FIRST, blocking assignment SECOND.
// The counter now behaves like a pipeline – it divides by two.

module counter_mixed_case2 (
    input  wire       clk,
    input  wire       rst_n,
    output wire [3:0] count
);

    reg  [3:0] count_reg;
    reg  [3:0] next_count;

    assign count = count_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_reg  <= 4'd0;
            next_count <= 4'd0;
        end else begin
            count_reg <= next_count;      // NON‑BLOCKING – uses OLD next_count
            next_count = count_reg + 1;   // BLOCKING   – updates next_count immediately
        end
    end

endmodule
