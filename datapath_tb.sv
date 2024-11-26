module datapath_tb();
    reg err;

    reg clk; 

    reg [2:0] readnum; 
    reg [1:0] vsel; 
    reg loada; 
    reg loadb; 

    reg [1:0] shift; 
    reg asel; 
    reg bsel; 
    reg [1:0] ALUop; 
    reg loadc; 
    reg loads;

    reg [2:0] writenum;
    reg write;
    reg [15:0] sximm8;
    reg [15:0] sximm5;

    wire [2:0] status_out;
    wire [15:0] datapath_out;

    reg [7:0] PC;
    reg [15:0] mdata;

    datapath DUT (
        .clk(clk),

        // register operand fetch stage
        .readnum    (readnum),
        .vsel       (vsel),
        .loada      (loada),
        .loadb      (loadb),

        // computation stage (sometimes called "execute")
        .shift      (shift),
        .asel       (asel),
        .bsel       (bsel),
        .ALUop      (ALUop),
        .loadc      (loadc),
        .loads      (loads),

        // set when "writing back" to register file
        .writenum   (writenum),
        .write      (write),  
        .sximm8     (sximm8),
        .sximm5     (sximm5),

        // outputs
        .status_out (status_out),
        .datapath_out(datapath_out),

        // for lab 7
        .PC         (PC),
        .mdata      (mdata)
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

    // for testing the Z flag output
    task check_status;  
        input [2:0] expected_S_out;
        begin
            // checking if Z is what we expect
            if( datapath_tb.DUT.status_out !== expected_S_out ) begin
                $display("ERROR ** status_out is %b, expected %b", datapath_tb.DUT.status_out, expected_S_out );
                err = 1'b1;
            end
        end
    endtask

    // for testing the output
    task check_data_out;  
        input [15:0] expected_datapath_out;
        begin
            // checking if output is what we expect
            if( datapath_tb.DUT.datapath_out !== expected_datapath_out ) begin
                $display("ERROR ** datapath_out is %b, expected %b", datapath_tb.DUT.datapath_out, expected_datapath_out );
                err = 1'b1;
            end
        end
    endtask

    initial begin
        err = 1'b0;

        //initialize inputs
        readnum = 3'b000;
        vsel = 2'b00;
        loada = 1'b0;
        loadb = 1'b0;

        shift = 2'b00; 
        asel = 1'b0; 
        bsel = 1'b0; 
        ALUop = 2'b00; 
        loadc = 1'b0; 
        loads = 1'b0;

        writenum = 3'b000;
        write = 1'b0;
        sximm8 = 16'b0;
        
        #10; //wait until after first rising edge, and before next rising edge
        
        // ****************************** //

        // MOV R0, #7 (10 ps)
        $display("MOV R0, #7;");
        sximm8 = 16'd7;
        vsel = 2'b10;
        writenum = 3'b000;
        write = 1'b1; #10; 
        check_status(3'bxxx);
        check_data_out({16{1'bx}});

        // MOV R1, #2 (20 ps)
        $display("MOV R1, #2;");
        sximm8 = 16'd2;
        vsel = 2'b10;
        writenum = 3'b001;
        write = 1'b1; #10;
        check_status(3'bxxx);
        check_data_out({16{1'bx}});

        // ADD R2, R1, R0, LSL#1 (30 ps)
        // cycle 1: store value in register B
        ALUop = 2'b00;

        $display("ADD R2, R1, R0, LSL#1;");
        readnum = 3'b000;
        loadb = 1'b1; #10;
        check_status(3'bxxx);
        check_data_out({16{1'bx}});
        loadb = 1'b0;

        // cycle 2: store value in register A (40 ps)
        readnum = 3'b001;
        loada = 1'b1; #10;
        check_status(3'bxxx);
        check_data_out({16{1'bx}});
        loada = 1'b0;

        // cycle 3: sum values and store in register C (50 ps)
        shift = 2'b01;
        asel = 1'b0;
        bsel = 1'b0;
        loadc = 1'b1; #10
        check_status(3'bxxx);
        check_data_out(16'd16);
        loadc = 1'b0;

        // cycle 4: write to register 2 (70 ps)
        vsel = 2'b00;
        writenum = 3'b010;
        write = 1'b1; #10
        check_status(3'bxxx);
        check_data_out(16'd16);

        // ****************************** //

        // MOV R3, #32 (80 ps)
        $display("MOV R3, #32;");
        vsel = 2'b10;
        sximm8 = 16'd32;
        writenum = 3'b011;
        write = 1'b1; #10;
        check_status(3'bxxx);
        check_data_out(16'd16);

        // SUB R4, R2, R3, LSR #1
        // cycle 1: store R3 value in register B (90 ps)
        ALUop = 2'b01;

        $display("SUB R4, R2, R3, LSR#1;");
        readnum = 3'b011;
        loadb = 1'b1; #10;
        check_status(3'bxxx);
        check_data_out(16'd16);
        loadb = 1'b0;

        // cycle 2: store R2 value in register A (100 ps)
        readnum = 3'b010;
        loada = 1'b1; #10;
        check_status(3'bxxx);
        check_data_out(16'd16);
        loada = 1'b0;

        // cycle 3: subtract values and store in register C (110 ps)
        shift = 2'b10;
        asel = 1'b0;
        bsel = 1'b0;
        loadc = 1'b1;
        loads = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'd0);
        loadc = 1'b0;
        loads = 1'b0;

        // cycle 4: write to register 4 (120 ps)
        vsel = 2'b00;
        writenum = 3'b100;
        write = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'd0);

        // ****************************** //

        // MOV R5, #-50 (130 ps)
        $display("MOV R5, #-50;");
        vsel = 2'b10;
        sximm8 = 16'b11001110;
        writenum = 3'b101;
        write = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd0);

        // AND R6, R5, R0
        // cycle 1: store R0 value in register B (140 ps)
        ALUop = 2'b10;

        $display("AND R6, R5, R0;");
        readnum = 3'b000;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd0);
        loadb = 1'b0;

        // cycle 2: store R5 value in register A (150 ps)
        readnum = 3'b101;
        loada = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd0);
        loada = 1'b0;

        // cycle 3: AND values and store in register C (160 ps)
        shift = 2'b00;
        asel = 1'b0;
        bsel = 1'b0;
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'b110);
        loadc = 1'b0;

        // cycle 4: write to register 6 (170 ps)
        vsel = 2'b00;
        writenum = 3'b110;
        write = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'b110);

        // ****************************** //
        
        // MVN R7, R0 (180 ps)
        ALUop = 2'b11;

        // cycle 1: negate R0, store in C (R0 already in reg B)
        $display("MVN R7, R0;");
        shift = 2'b00;
        asel = 1'b0;
        bsel = 1'b0;
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out({{13{1'b1}}, 3'b0});
        loadc = 1'b0;

        // cycle 4: write to register 7 (190 ps)
        vsel = 2'b00;
        writenum = 3'b111;
        write = 1'b1; #10
        check_status(3'b001);
        check_data_out({{13{1'b1}}, 3'b0});
        write = 1'b0;

        // ****************************** //

        // test asel = 1 and bsel = 1 with sximm5 = 10000 (200 ps)
        $display("16'b0 + sximm5");
        sximm5 = 16'd16;
        asel = 1'b1;
        bsel = 1'b1;
        ALUop = 2'b00;
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'd16);
        loadc = 1'b0;

        // ****************************** //

        // make sure all registers are what we expect (read through all registers) (210 ps)
        $display("reading R0-R7");
        readnum = 3'b000;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd16);
        loadb = 1'b0;
        
        // R0 should be 7 (220 ps)
        asel = 1'b1;
        bsel = 1'b0;
        ALUop = 2'b00;
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'd7);
        loadc = 1'b0;

        // Put R1 in register B (230 ps)
        readnum = 3'b001;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd7);
        loadb = 1'b0;
        
        // R1 should be 2 (240 ps)
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'd2);
        loadc = 1'b0;

        // Put R2 in register B (250 ps)
        readnum = 3'b010;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd2);
        loadb = 1'b0;
        
        // R2 should be 16 (260 ps)
        loadc = 1'b1;#10
        check_status(3'b001);
        check_data_out(16'd16);
        loadc = 1'b0;

        // Put R3 in register B (270 ps)
        readnum = 3'b011;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd16);
        loadb = 1'b0;
        
        // R3 should be 32 (280 ps)
        loadc = 1'b1;#10
        check_status(3'b001);
        check_data_out(16'd32);
        loadc = 1'b0;

        // Put R4 in register B (290 ps)
        readnum = 3'b100;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd32);
        loadb = 1'b0;
        
        // R4 should be 0 (300 ps)
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'd0);
        loadc = 1'b0;

        // Put R5 in register B (310 ps)
        readnum = 3'b101;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'd0);
        loadb = 1'b0;
        
        // R5 should be -50 (320 ps)
        loadc = 1'b1;#10
        check_status(3'b001);
        check_data_out(16'b11001110);
        loadc = 1'b0;

        // Put R6 in register B (330 ps)
        readnum = 3'b110;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'b11001110);
        loadb = 1'b0;
        
        // R6 should be 16'b110 (340 ps)
        loadc = 1'b1; #10
        check_status(3'b001);
        check_data_out(16'b110);
        loadc = 1'b0;

        // Put R7 in register B (350 ps)
        readnum = 3'b111;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out(16'b110);
        loadb = 1'b0;
        
        // R7 should be {{13{1'b1}}, 3'b0} (360 ps)
        loadc = 1'b1;#10
        check_status(3'b001);
        check_data_out({{13{1'b1}}, 3'b0});
        loadc = 1'b0;

        ///////////////////// testing status flag //////////////////////////
        ALUop = 2'b01;

        // put r5 = -50 in reg A
        readnum = 3'b101;
        loada = 1'b1; #10;
        check_status(3'b001);
        check_data_out({{13{1'b1}}, 3'b0});
        loada = 1'b0;

        // put 100 in R6

        vsel = 2'b10;
        sximm8 = 16'd100;
        writenum = 3'b110;
        write = 1'b1; #10;
        check_status(3'b001);
        check_data_out({{13{1'b1}}, 3'b0});

        // put r6 in reg B

        readnum = 3'b110;
        loadb = 1'b1; #10;
        check_status(3'b001);
        check_data_out({{13{1'b1}}, 3'b0});
        loadb = 1'b0;

        // N flag should be 1

        loads = 1'b1; #10;
        check_status(3'b100);
        check_data_out({{13{1'b1}}, 3'b0});
        loads = 1'b0;

        // put 1 in R0

        vsel = 2'b10;
        sximm8 = 16'd1;
        writenum = 3'b000;
        write = 1'b1; #10;
        check_status(3'b100);
        check_data_out({{13{1'b1}}, 3'b0});

        // put r0 in reg A

        readnum = 3'b000;
        loada = 1'b1; #10;
        check_status(3'b100);
        check_data_out({{13{1'b1}}, 3'b0});
        loada = 1'b0;

        // put max negativ int in R1

        vsel = 2'b10;
        sximm8 = {1'b1, {15{1'b0}}};
        writenum = 3'b001;
        write = 1'b1; #10;
        check_status(3'b100);
        check_data_out({{13{1'b1}}, 3'b0});

        // put r1 in reg B

        readnum = 3'b001;
        loadb = 1'b1; #10;
        check_status(3'b100);
        check_data_out({{13{1'b1}}, 3'b0});
        loadb = 1'b0;

        // N flag should be 1, V flag should be 1

        loadc = 1'b1;
        loads = 1'b1; #10;
        check_status(3'b110);
        check_data_out({1'b1, {15{1'b0}}});
        loads = 1'b0;
        loadc = 1'b0;

        if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end

endmodule
