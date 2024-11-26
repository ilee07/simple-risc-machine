module lab7_top_tb;
    reg [3:0] KEY;
    reg [9:0] SW;
    wire [9:0] LEDR; 
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg err;

    lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

    // loop clock every 5 seconds
    initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
    end

    initial begin
        err = 0;
        KEY[1] = 1'b0; // reset asserted

        @(negedge KEY[0]); // wait until next falling edge of clock

        KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

        #10; // waiting for RST state to cause reset of PC

        // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
        if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end
        
        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X
        
        if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, X

        if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
        if (DUT.CPU.DP.REGFILE.R0 !== 16'd11) begin err = 1; $display("FAILED: R0 should be 11."); $stop; end  // because MOV R0, X should have occurred

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 3 *after* executing LDR R1, [R0]
        
        if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
        if (DUT.CPU.DP.REGFILE.R1 !== 16'hABCD) begin err = 1; $display("FAILED: R1 should be 0xABCD. Looks like your LDR isn't working."); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 4 *after* executing MOV R2, Y

        if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
        if (DUT.CPU.DP.REGFILE.R2 !== 16'd12) begin err = 1; $display("FAILED: R2 should be 12."); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 5 *after* executing STR R1, [R2]
    
        if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
        if (DUT.MEM.mem[12] !== 16'hABCD) begin err = 1; $display("FAILED: mem[12] wrong; looks like your STR isn't working"); $stop; end
        

        // ***** new tests ****** //

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC set to 6 *after* executing MOV R3, #8
    
        if (DUT.CPU.PC !== 9'd6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
        if (DUT.write_data !== 16'hABCD) begin err = 1; $display("FAILED: write_data should be 0xABCD"); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC set to 7 *after* executing MOV R4, R3
    
        if (DUT.CPU.PC !== 9'd7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
        if (DUT.write_data !== 16'd8) begin err = 1; $display("FAILED: write_data should be 8"); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC set to 8 *after* executing ADD R5, R4, R3
    
        if (DUT.CPU.PC !== 9'd8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
        if (DUT.write_data !== 16'd16) begin err = 1; $display("FAILED: write_data should be 16"); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC set to 9 *after* executing CMP R4, R5 
    
        if (DUT.CPU.PC !== 9'd9) begin err = 1; $display("FAILED: PC should be 9."); $stop; end
        if (DUT.HEX5[6] !== 1'b0) begin err = 1; $display("FAILED: N flag should be set"); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC set to 10 *after* executing AND R6, R3, R4
    
        if (DUT.CPU.PC !== 9'd10) begin err = 1; $display("FAILED: PC should be 10."); $stop; end
        if (DUT.write_data !== 16'b0) begin err = 1; $display("write_data should be 0"); $stop; end

        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC set to 11 *after* executing MVN R7, R6
    
        if (DUT.CPU.PC !== 9'd11) begin err = 1; $display("FAILED: PC should be 11."); $stop; end
        if (DUT.write_data !== 16'b1111111111111111) begin err = 1; $display("FAILED: write_data should be -1 in two's complement"); $stop; end
        
        // ****** If HALT working PC will stay at 11 ****** //

        #100;
        if (DUT.CPU.PC !== 9'd11) begin err = 1; $display("FAILED: PC should be 11."); $stop; end

        if (~err) $display("PASSED");
            else $display("FAILED");
        $stop;
    end
endmodule
