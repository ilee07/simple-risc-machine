module cpu_tb();
    reg err;

    reg clk, reset;
    reg [15:0] read_data;
    wire [1:0] mem_cmd;
    wire [8:0] mem_addr;
    wire [15:0] write_data;
    wire N, V, Z, w;

    cpu DUT( .clk   (clk), // recall from Lab 4 that KEY0 is 1 when NOT pushed
        .reset (reset), 
        .read_data    (read_data),
        .mem_cmd (mem_cmd),
        .mem_addr (mem_addr),
        .write_data (write_data),
        .Z     (Z),
        .N     (N),
        .V     (V),
        .w     (w)
    );

    //Simulating the clock changing every 5 time units
    initial begin
        clk = 1'b0; #5;
        forever begin
            // posedge
            clk = 1'b1; #5;
            // negedge
            clk = 1'b0; #5;
        end
    end

    // Check if in wait state
    task check_state;  
        input expected_w;
        begin
            if( cpu_tb.DUT.w !== expected_w ) begin
                $display("ERROR ** w is %b, expected %b", cpu_tb.DUT.w, expected_w );
                err = 1'b1;
            end
        end
    endtask

    // Check if write_data is expected
    task check_data_write_data;  
        input [15:0] expected_write_data;
        begin
            if( cpu_tb.DUT.write_data !== expected_write_data ) begin
                $display("ERROR ** write_data is %b, expected %b", cpu_tb.DUT.write_data, expected_write_data );
                err = 1'b1;
            end
        end
    endtask

    // Check if status is expected
    task check_status;  
        input expected_N;
        input expected_V;
        input expected_Z;
        begin
            if( cpu_tb.DUT.N !== expected_N) begin
                $display("ERROR ** N is %b, expected %b", cpu_tb.DUT.N, expected_N);
                err = 1'b1;
            end
            if( cpu_tb.DUT.V !== expected_V) begin
                $display("ERROR ** V is %b, expected %b", cpu_tb.DUT.V, expected_V);
                err = 1'b1;
            end
            if( cpu_tb.DUT.Z !== expected_Z) begin
                $display("ERROR ** Z is %b, expected %b", cpu_tb.DUT.Z, expected_Z);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        err = 1'b0;

        //initialize inputs
        read_data = 16'b0;

        reset = 1'b1; #10; 
        reset = 1'b0; // go to wait state

        // ******** MOV Rn,#<im8> ********* //
        
        // TEST 1 : MOV R0, # 8'sb01111111
        read_data = 16'b110_10_000_01111111; #10;

        #50 // (50-60 ps)
        check_state(1'b1);
        check_data_write_data({16{1'bx}});
        check_status(1'bx, 1'bx, 1'bx);

        // TEST 2 : MOV R1, # -1
        read_data = 16'b110_10_001_11111111; 

        #40 // (80-90 ps)
        check_state(1'b1);
        check_data_write_data({16{1'bx}});
        check_status(1'bx, 1'bx, 1'bx);

        // TEST 3 : MOV R2, #16
        read_data = 16'b110_10_010_00010000;

        #40 // (110-120 ps)
        check_state(1'b1);
        check_data_write_data({16{1'bx}});
        check_status(1'bx, 1'bx, 1'bx); 
        
        // ******** MOV Rn,#<im8> ********* //

        // TEST 1 : MOV R3, R2 LSL #1
        read_data = 16'b110_00_000_011_01_010; // load instruction

        #60; // (160-170)  go to wait state
        check_state(1'b1);
        check_data_write_data(16'd32);
        check_status(1'bx, 1'bx, 1'bx);

        // TEST 2 : MOV R4, R2 LSR #1 (170-220 ps)  
        read_data = 16'b110_00_000_100_10_010; // load instruction
    
        #60;
        check_state(1'b1);
        check_data_write_data(16'd8);
        check_status(1'bx, 1'bx, 1'bx);

        // TEST 3 : MOV R5, R1 LSR #1 (with MSB copy B[15]) (220-270 ps)
        read_data = 16'b110_00_000_101_11_001; // load instruction

        #60;
        check_state(1'b1);
        check_data_write_data({16{1'b1}});
        check_status(1'bx, 1'bx, 1'bx);
        
        // ******** ADD Rd, Rn, Rm{,<sh_op>} ********* //

        // TEST 1 : ADD R5, R5, R1 (270-330 ps)
        read_data = 16'b101_00_101_101_00_001; // load instruction
   
        #70;
        check_state(1'b1);
        check_data_write_data({{15{1'b1}}, 1'b0});
        check_status(1'bx, 1'bx, 1'bx);

        // TEST 2 : ADD R6, R5, R2 (330-390 ps)
        read_data = 16'b101_00_101_110_00_010; // load instruction
 
        #70;
        check_state(1'b1);
        check_data_write_data(16'd14);
        check_status(1'bx, 1'bx, 1'bx);

        // TEST 3 : ADD R6, R6, R5 LSR #1 (with msb = B[15]) (390-450 ps)
        read_data = 16'b101_00_110_110_11_101; // load instruction

        #70;
        check_state(1'b1);
        check_data_write_data(16'd13);
        check_status(1'bx, 1'bx, 1'bx);
        
        // ******** CMP Rn, Rm{,<sh_op>}  ********* //

        // TEST 1 : CMP R2, R6 (450-500 ps)
        read_data = 16'b101_01_010_000_00_110; // load instruction
   
        #60;
        check_state(1'b1);
        check_data_write_data(16'd13);
        check_status(1'b0, 1'b0, 1'b0);

        // TEST 2 : CMP R6, R2 (500-550 ps)
        read_data = 16'b101_01_110_000_00_010; // load instruction
      
        #60;
        check_state(1'b1);
        check_data_write_data(16'd13);
        check_status(1'b1, 1'b0, 1'b0);

        // TEST 3 : CMP R1, R1 (550-600 ps)
        read_data = 16'b101_01_001_000_00_001; // load instruction

        #60;
        check_state(1'b1);
        check_data_write_data(16'd13);
        check_status(1'b0, 1'b0, 1'b1);

        // ******** AND Rd, Rn, Rm{,<sh_op>} ********* //

        // TEST 1 : AND R7, R0, R1 (600-660 ps)
        read_data = 16'b101_10_000_111_00_001; // load instruction

        #70;
        check_state(1'b1);
        check_data_write_data(16'b01111111);
        check_status(1'b0, 1'b0, 1'b1);

        // TEST 2 : AND R7, R0, R1 LSL #1 (660-720 ps)
        read_data = 16'b101_10_000_111_01_001; // load instruction

        #70;     
        check_state(1'b1);
        check_data_write_data(16'b01111110);
        check_status(1'b0, 1'b0, 1'b1);

        // TEST 3 : AND R7, R0, R2 LSR #1 (720-780 ps)
        read_data = 16'b101_10_000_111_10_010; // load instruction

        #70;
        check_state(1'b1);
        check_data_write_data(16'b00001000);
        check_status(1'b0, 1'b0, 1'b1);

        // ******** MVN Rd, Rm{,<sh_op>} ********* //

        // TEST 1 : MVN R7, R1 (780-830)
        read_data = 16'b101_11_000_111_00_001; // load instruction

        #60;
        check_state(1'b1);
        check_data_write_data(16'b0);
        check_status(1'b0, 1'b0, 1'b1);

        // TEST 2 : MVN R7, R2 LSL #1 (830-880)
        read_data = 16'b101_11_000_111_01_010; // load instruction

        #60;
        check_state(1'b1);
        check_data_write_data(16'b111_111_111_101_1111);
        check_status(1'b0, 1'b0, 1'b1);

        // TEST 3 : MVN R7, R7 LSL #1 (880-930)
        read_data = 16'b101_11_000_111_01_111; // load instruction
    
        #60;
        check_state(1'b1);
        check_data_write_data(16'b000_000_000_100_0001);
        check_status(1'b0, 1'b0, 1'b1);

        if (~err) $display("PASSED");
        else $display("FAILED");

        $stop;
    end

endmodule
