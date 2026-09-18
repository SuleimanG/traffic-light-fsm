module tb_top_module ();

    // signal declaration
    logic T_A, T_B, clk, rst;
    logic [1:0] L_A, L_B;
    logic done; // signal to indicate when the counter is done

    int errors = 0;  //  error counter   

    // module instantiation
    traffic_light_fsm dut(
        .T_A(T_A),
        .T_B(T_B),
        .clk(clk),
        .RESET(rst),
        .L_A(L_A),
        .L_B(L_B),
        .done(done)
    );

    // clock generation
    initial
        begin
            clk = 0;
            forever #5 clk = ~clk;
        end

    task check_transition(
        input logic ta, tb,
        input logic [1:0] exp_LA, exp_LB,
        input logic wait_for_done // whether to wait for the counter to finish
    );

        T_A = ta;
        T_B = tb;

        @(posedge clk); //  wait one cycle
        if (wait_for_done)
            begin
                wait(done); // wait for the counter to finish
              	@(posedge clk); // wait for the next clock edge after done is asserted
            end
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
            check_transition(
                .ta(1'b1),
                .tb(1'b0),    // don't care, can be assigned to either 0 or 1
                .exp_LA(2'b00), .exp_LB(2'b10), // 00 green, 01 yellow, 10 red
                .wait_for_done(1'b0)
            );

            // test case 2: S0 --> S1
            check_transition(
                .ta(1'b0),
                .tb(1'b0),    // don't care, can be assigned to either 0 or 1
                .exp_LA(2'b01), .exp_LB(2'b10), // 00 green, 01 yellow, 10 red
                .wait_for_done(1'b0)    
            );

            // test case 3: S1 --> S2
            check_transition(
                .ta(1'b1),    // don't care, can be assigned to either 0 or 1
                .tb(1'b0),    // don't care, can be assigned to either 0 or 1
                .exp_LA(2'b10), .exp_LB(2'b00), // 00 green, 01 yellow, 10 red
                .wait_for_done(1'b1) // wait for the counter to finish
            );

            // test case 4: S2 --> S2
            check_transition(
                .ta(1'b1),    // don't care, can be assigned to either 0 or 1
                .tb(1'b1),    
                .exp_LA(2'b10), .exp_LB(2'b00), // 00 green, 01 yellow, 10 red
                .wait_for_done(1'b0)
            );

            // test case 5: S2 --> S3
            check_transition(
                .ta(1'b0),    // don't care, can be assigned to either 0 or 1
                .tb(1'b0),    
                .exp_LA(2'b10), .exp_LB(2'b01), // 00 green, 01 yellow, 10 red
                .wait_for_done(1'b0)
            );

            // test case 6: S3 --> S0
            check_transition(
                .ta(1'b1),    // don't care, can be assigned to either 0 or 1
                .tb(1'b0),    // don't care, can be assigned to either 0 or 1
                .exp_LA(2'b00), .exp_LB(2'b10), // 00 green, 01 yellow, 10 red
                .wait_for_done(1'b1) // wait for the counter to finish
            );

            // hold final state briefly so the waveform viewer can render it
            @(posedge clk);
            #1;

            $display("Test complete: %0d error(s)", errors);
            $finish;       // ends the simulation
        end

endmodule
