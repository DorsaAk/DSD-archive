module clk_gen #(parameter PERIOD = 10, SKEW = 0) (
    output clk_master,
    output clk_early,
    output clk_late
);
    reg master;
    reg late;
    initial master = 0;
    always #(PERIOD/2) master = ~master;
    assign clk_master = master;
    assign clk_early = master;
    always @(master) late <= #(SKEW) master; // transport delay
    assign clk_late = late;
endmodule

