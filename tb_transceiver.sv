/*

MODULE: tb_transceiver.sv
    This is the testbench that simulates the whole serial communication system modeled, consisting of both transmitter side and receiver side.
The concepts of timescale and signed number comparison (two of the main topics of the assignment) are used within thus module.

*/

`timescale 1ns/1ps  // the unit of 1ns, with the precision of 1ps

module tb_transceiver;

    // ------ parameters ------
    parameter DATA_WIDTH = 4;

    // ------ Testbench Signals ------
    logic clk;
    logic reset_n;
    logic start;
    logic signed [DATA_WIDTH-1 : 0] data_in;
    logic serial_line; // this connects the transmitter;s output to the receiver;s input
    logic signed [DATA_WIDTH-1 : 0] data_out;
    logic data_valid;

    // ------ file descriptor for saving the log file ------
    int fd;

    // ===================== Instantiations =====================
    // The transmitter
    tx_fsm #(.DATA_WIDTH (DATA_WIDTH)) dut_tx (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .data_in(data_in),
        .serial_out(serial_line)
    );
    // The receiver
    rx_fsm #(.DATA_WIDTH (DATA_WIDTH)) dut_rx (
        .clk(clk),
        .reset_n(reset_n),
        .seria_in(serial_line),
        .data_out(data_out),
        .data_valid(data_valid)
    )

    // ------ Generating a 50MHz clk signal ------
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
        // In the line above the delay #10 is calculated using the time unit 10ns, which was defined by timescale.
        // half_cycle = 10 * 10^-9 -> full_cycle = 20 * 10^-9 -> freq = 0.05 * 10^9 = 50MHz
    end 
    

    //* ============ The Test Sequence ============
    initial begin
        //# open the log file for writing
        fd = $fopen("tb_log_file.txt", "w");  // "w" denotes completely overwriting the file each run
        if (fd == 0) begin
            $display("Error: Could not open file.");
            $finish;
        end

        //# Initialize
        reset_n = 0;
        start = 0;
        data_in = 0;

        //# Apply reset
        #45;
        reset_n = 1;
        #20;

        $fdisplay(fd, "Starting Transceiver Tests...");

        //# Send test cases
        send_and_check(4'sd3);   // Positive
        send_and_check(4'sd0);   // Zero
        send_and_check(-4'sd4);  // Negative
        send_and_check(4'sd7);   // Max positive (+7)
        send_and_check(-4'sd8);  // Min negative (-8)
        send_and_check(-4'sd1);  // Negative (-1)

        //# End sim and close the log file
        #50;
        $fdisplay(fd, "Simulation complete.");
        $display("Simulation complete. Check tb_log_file.txt for results.");
        $fclose(fd);
        $finish;
    end


    
    //* ============ Task for handling the check ============
    task send_and_check(input logic signed [DATA_WIDTH-1 : 0] test_val);
        begin
            @(posedge clk);
            data_in = test_val;
            start = 1;

            @(posedge clk);
            start = 0;

            //# Now waiting for data_valid to be asserted (by the RX side)
            wait (data_valid == 1'b1);

            //# Compare and log both to console and the text file
            // This is where the concept of comparing signed numbers in (System)Verilog is used.
            // As we have defined the data bits as signed numbers (both in the modules and in the testbench), the comparison performed automatically
            // takes the signes into account.
            if (data_out === test_val) begin  // More about the '===' operator at the end of the code...
                $display("PASS: Sent %0d, Received %0d", test_val, data_out);
                $fdisplay(fd, "PASS: Sent %0d, Received %0d", test_val, data_out);
            end
            else begin
                $error("FAIL: Sent %0d, Received %0d", test_val, data_out);
                $fdisplay(fd, "FAIL: Sent %0d, Received %0d", test_val, data_out);
            end

            @(posedge clk);
            #40;
        end
    endtask

endmodule


//# About the operator === in SystemVerilog:
/*
    '===' is used to compare values that might contain x (unknown) or z (high impedance) states, ensuring an exact bit-by-bit match across all four states (0, 1, x, z).
    The regular '==' only compares 0 and 1. If there is an x or z in either of the operands being compared, the result of the comparison is x (unknown).
    
    For the case occuring in the code, it's safer to use '===' in order to cover the potential failures and x/z generating of the modules under test.
*/