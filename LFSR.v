/*

    MODULE: LFSR.v
    
    PORTS:
        inputs: clk, rst_n, en, load, init_state
        outputs: state, valid
    
    PARAMETERS:
        WIDTH, TAPS
    
    DESCRIPTION:
        Models a simple, parametrized Fibonacci LFSR.

*/

module LFSR #(
    parameter WIDTH = 8,  // represents the number of flip flops in the structure of the LFSR
    parameter TAPS = 8'hB8  // this value for TAPS (1011 1000) garauntees a maximal-length sequence (longest period)
)(
    input wire clk,
    input wire rst_n,  // active-low asynchronous reset
    input wire en,  // enable shift
    input wire load,  // synchronous load
    input wire [WIDTH-1:0] init_state,  // value to load, equivalent to "seed"
    output reg [WIDTH-1:0] state,  // current LFS
    output wire valid  // high is state is not all zeros (and the LFSR is not stuck)
)

    //* ---------------------------------------------------------
    //* 1. Generate Statement: Parameterized Feedback Logic
    //* ---------------------------------------------------------
    wire [WIDTH:0] feedback_chain;
    assign feedback_chain[0] = 1'b0;  // base case for the XOR chain

    genvar i;
    generate  //# refer to the end of the code on why we need a generate statement here
        for(i=0; i<WIDTH, i=i+1) begin: feedback_loop
            assign feedback_chain[i+1] = feedback_chain[i] ^ state[i];
            // OR:
            // If TAPS[i] is 1, XOR the corresponding state bit. 
            // If TAPS[i] is 0, just pass the previous chain value.
            // assign feedback_chain[i+1] = TAPS[i] ? (feedback_chain[i] ^ state[i]) : feedback_chain[i];
        end
    endgenerate

    // The final bit in the chain is our feedback bit
    wire feedback_bit = feedback_chain[WIDTH];


    //* ---------------------------------------------------------
    //* 2. Sequential Logic: State Updates
    //* ---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin // asynch. reset
        if(!rst_n) begin
            // set to all 1s on reset to prevent getting stuck in 0
            state <= {WIDTH{1'b'1}};
        end else if (load) begin
            // synchronous load
            // prevent loading all 0s (load all 1s instead)
            if(init_state == {WIDTH{1'b0}})
                state <= {WIDTH{1'b1}};
            else
                state <= init_state; // if not all zero, load the value into state
        end else if (en) begin
                //! shift right and insert the calculated feedback bit at MSB
                state <= {feedback_bit, state[WIDTH-1:1]}
        end
    end

    //* ---------------------------------------------------------
    //* 3. Function Definition: Valid State Check
    //* ---------------------------------------------------------
    // A combinational function to check if the state is non-zero
    //# For more on the use of `function`, refer to the end of the code
    function automatic logic is_valid_state(input [WIDTH-1:0] current_state);
        begin
            is_valid_state = (current_state != {WIDTH{1'b0}});
        end
    endfunction

    assign valid = is_valid_state(state);

endmodule


//# About the `generate` statement
/*
    We needed an LFSR where the WIDTH and TAPS can change depending on where the module is instantiated.
    Also, the nature of the structure has a loop and interation notion to it, but we cannot use a
    standard procedural for loop to wire up module-level assign statements.

    We used generate for with a genvar i to iterate through the TAPS parameter.

    HARDWARE IMPLICATION POV:
        A generate block is evaluated before synthesis. The synthesizer 'unrolls' the loop structure inside
        it an stamps out as much hardware blocks as is equivalent to the loop written.
*/

//# About the `function`
/*
    Functions are used to encapsulate pices of combinational lofic that we want to reuse for scalability or isolate for
    readability. They take inputs, execute instantly and return exactly one value.

    What we did here: We defined is_valid_state to check if the current_state is non-zero.
    We then called this function in a continuous assign valid = ... statement.

    HARDWARE IMPLICATION POV:
        Synthesizable functions map purely to combinational logic gates (AND, OR, NOT, etc.).
        They cannot contain flip-flops, memory, or time delays (like #5 or @(posedge clk)). In this specific case,
        the function synthesizes into a wide OR-gate tree (if any bit is 1, it returns 1).

*/