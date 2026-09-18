typedef enum logic [1:0] {S0,S1,S2,S3} state_t;

module traffic_light_fsm (
    input  logic T_A, T_B,
    input  logic clk, RESET,
    output logic [1:0] L_A, L_B,
    output logic done // signal to indicate when the counter is done
);

    // FSM state wires
    state_t S, NS;

    // First combinational block
    next_state_logic c1(
        .T_A(T_A),
        .T_B(T_B),
        .S(S),
        .done(done),
        .NS(NS)
    );

    // Register 
    state_register r1(
        .clk(clk),
        .rst_high(RESET),
        .NS(NS),
        .S(S)
    );

    // Counter block
    counter #(.YELLOW_DURATION(3)) o1(
        .clk(clk),
        .S(S),
        .RESET(RESET),  // asynchoronous active high reset
        .done(done)
    );

    // Second combinational block
    output_logic c2 (
        .S(S),
        .L_A(L_A),
        .L_B(L_B)
    );


endmodule



module next_state_logic (
    input  state_t S,       // current state
    input  logic T_A, T_B,      // Traffic control sensors
    input  logic done,       //  counter's output
    output state_t NS       // next state
);
    //  combinational logic
    always_comb
        begin
            case (S)
                S0: NS = T_A ? S0 : S1;
                S1: NS = done? S2 : S1;
                S2: NS = T_B ? S2 : S3;
                S3: NS = done? S0 : S3;
                default: NS = S0;
            endcase  
        end
endmodule

module output_logic (
    input state_t S,                //  State encoding
    output logic [1:0] L_A, L_B         //  Traffic light encoding
);
    // combinational logic
    assign L_A [1] = S[1];
    assign L_A [0] = ~S[1] & S[0];
    assign L_B [1] = ~S[1];
    assign L_B [0] = S[1] & S[0];
endmodule

module state_register (
    input   logic clk,
    input   state_t NS,      // next state
    input   logic rst_high,      // asynchronous active high reset
    output  state_t S      // current state
);

    always_ff @(posedge clk or posedge rst_high)
        begin
            if (rst_high)
                begin
                    S <= S0;
                end
            else
                begin
                    S <= NS;
                end
        end
endmodule

module counter #(
    parameter YELLOW_DURATION = 3      // for a dynamic duration input
) 
                (
    input   logic clk, RESET,
    input   state_t S,      //  current state
    output  logic done      //  done counting
);
    logic [7:0] counter;    // 8-bit counter

    always_ff @(posedge clk or posedge RESET)
        begin
            if (!RESET)
                begin
                    if (S == S1 || S == S3)
                        begin
                            if (YELLOW_DURATION == counter)
                                begin
                                    done <= 1'b1;
                                    counter <= 0;
                                end
                            else
                                begin
                                    counter <= counter + 8'h01; // increment counter, counter transiently increments one extra cycle after S leaves S1/S3 due to edge-race condition, however it is harmless since it self corrects in the next cycle
                                    done <= 0;
                                end
                        end
                    else
                        begin
                            done <= 0;
                            counter <= 0;
                        end
                end

            else
                begin
                    counter <= 0;
                    done <= 0;
                end
        end

endmodule
