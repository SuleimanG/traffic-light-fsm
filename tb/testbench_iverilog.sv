module tb_top_module ();

    // signal declaration
    logic T_A, T_B, clk, rst;
    logic [1:0] L_A, L_B;

    int errors = 0;  //  error counter   

    // module instantiation
    traffic_light_fsm dut(
        .T_A(T_A),
        .T_B(T_B),
        .clk(clk),
        .RESET(rst),
        .L_A(L_A),
        .L_B(L_B)
    );

    // clock generation
    initial
        begin
            clk = 0;
            forever #5 clk = ~clk;
        end

    task check_transition(
        input logic ta, tb,
        input logic [1:0] exp_LA, exp_LB
    );

        T_A = ta;
        T_B = tb;

        @(posedge clk); //  wait one cycle
        #1; //  delta waiting time
        if (L_A !== exp_LA || L_B !== exp_LB)   //  check for expected output
            begin
            $display("FAILED AT T_A=%b, T_B=%b: Expected L_A=%b, L_B=%b but got L_A=%b, L_B=%b", ta, tb, exp_LA, exp_LB, L_A, L_B);
            errors++;
            end
        else
            begin
            $display("PASSED AT T_A=%b, T_B=%b: L_A=%b, L_B=%b", ta, tb, L_A, L_B);
            end
    endtask

    initial
        begin
            // dumpfile/dumpvars
            $dumpfile("tb_top_module.vcd");
            $dumpvars(0, tb_top_module);

            // reset the DUT
            rst = 1;
            @(posedge clk);
            #1;
            rst = 0;

            // test cases

            // test case 1: S0 --> S0
            // tb don't care, can be assigned to either 0 or 1
            check_transition(1, 0, 2'b00, 2'b10); // 00 green, 01 yellow, 10 red

            // test case 2: S0 --> S1
            // tb don't care, can be assigned to either 0 or 1
            check_transition(0, 0, 2'b01, 2'b10);

            // test case 3: S1 --> S2
            // ta, tb don't care, can be assigned to either 0 or 1
            check_transition(1, 0, 2'b10, 2'b00);

            // test case 4: S2 --> S2
            // ta don't care, can be assigned to either 0 or 1
            check_transition(1, 1, 2'b10, 2'b00);

            // test case 5: S2 --> S3
            // ta don't care, can be assigned to either 0 or 1
            check_transition(0, 0, 2'b10, 2'b01);

            // test case 6: S3 --> S0
            // ta, tb don't care, can be assigned to either 0 or 1
            check_transition(1, 0, 2'b00, 2'b10);

            // hold final state briefly so the waveform viewer can render it
            @(posedge clk);
            #1

            $display("Test complete: %0d error(s)", errors);
            $finish;       // ends the simulation
        end

endmodule
