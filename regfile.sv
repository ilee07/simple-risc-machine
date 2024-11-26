module regfile(data_in, writenum, write, readnum, clk, data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    // fill out the rest

    wire [7:0] readSel;
    wire [7:0] writeSel;

    wire [15:0] R0;
    wire [15:0] R1;
    wire [15:0] R2;
    wire [15:0] R3;
    wire [15:0] R4;
    wire [15:0] R5;
    wire [15:0] R6;
    wire [15:0] R7;

    wire [7:0] en;

    // 3:8 decoder from binary to one hot for writing to registers
    Dec #(3, 8) writeDec(writenum, writeSel);

    // enable
    assign en = {8{write}} & writeSel;

    // 16 bit load enabled register for r0
    vDFFE #(16) reg0(clk, en[0], data_in, R0);
    // 16 bit load enabled register for r1
    vDFFE #(16) reg1(clk, en[1], data_in, R1);
    // 16 bit load enabled register for r2
    vDFFE #(16) reg2(clk, en[2], data_in, R2);
    // 16 bit load enabled register for r3
    vDFFE #(16) reg3(clk, en[3], data_in, R3);
    // 16 bit load enabled register for r4
    vDFFE #(16) reg4(clk, en[4], data_in, R4);
    // 16 bit load enabled register for r5
    vDFFE #(16) reg5(clk, en[5], data_in, R5);
    // 16 bit load enabled register for r6
    vDFFE #(16) reg6(clk, en[6], data_in, R6);
    // 16 bit load enabled register for r7
    vDFFE #(16) reg7(clk, en[7], data_in, R7);

    // 3:8 decoder from binary to one hot for reading registers
    Dec #(3, 8) readDec(readnum, readSel);

    // 8 input, 16 bit multiplexer for reading registers
    MUX8 #(16) MUX8(R7, R6, R5, R4, R3, R2, R1, R0, readSel, data_out);
endmodule

// Register with load enabled
module vDFFE(clk, en, in, out) ;
    parameter n = 1;  // width
    input clk, en ;
    input  [n-1:0] in ;
    output [n-1:0] out ;
    reg    [n-1:0] out ;
    wire   [n-1:0] next_out ;

    // if load is enabled, next output will be the input, otherwise don't change the output
    assign next_out = en ? in : out; 

    // on rising edge of clock assign output to the next output
    always @(posedge clk)
        out = next_out;  
endmodule

// an n:m decoder with binary input 'a' (n bits wide) and one hot output 'b' (m bits wide)
module Dec(a, b) ;
    parameter n=2 ;
    parameter m=4 ;

    input  [n-1:0] a ;
    output [m-1:0] b ;

    wire [m-1:0] b = 1 << a ;
endmodule

// 8-input, k-bit MUX8 with one-hot select 
module MUX8(r7, r6, r5, r4, r3, r2, r1, r0, select, out) ;
    parameter k = 1 ;
    input [k-1:0] r7, r6, r5, r4, r3, r2, r1, r0;  // inputs
    input [7:0] select; // one-hot select
    output[k-1:0] out;
    reg [k-1:0] out;
    
    // select output based on input
    always_comb begin
        case(select) 
        8'b00000001: out = r0;
        8'b00000010: out = r1;
        8'b00000100: out = r2;
        8'b00001000: out = r3;
        8'b00010000: out = r4;
        8'b00100000: out = r5;
        8'b01000000: out = r6;
        8'b10000000: out = r7;
        default: out =  {k{1'bx}};
        endcase
    end
endmodule
