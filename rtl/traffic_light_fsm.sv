typedef enum logic [1:0] {S0,S1,S2,S3} state_t;
state_t S, NS;

module traffic_light_fsm (
    input  logic T_A, T_B,
    input  logic clk, RESET,
    output logic [1:0] L_A, L_B
);
    // First combinational block
    next_state_logic c1(
        .S(S),
        .T_A(T_A),
        .T_B(T_B),
        .NS(NS)
    );

    // Register 
    state_register r1(
        .clk(clk),
        .rst_high(RESET),
        .NS(NS),
        .S(S)

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
    output state_t NS       // next state
);
    //  combinational logic
    assign NS [0] = ( ~T_A & ~S[1] & ~S[0] ) | ( ~T_B & S[1] & ~S[0]);
    assign NS [1] = S[1] ^ S[0];
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
    input   logic rst_high,      // reset active high
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
