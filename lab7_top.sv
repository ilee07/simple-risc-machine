`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire clk = ~KEY[0];

    wire [8:0] mem_addr;
    wire write;
    wire [15:0] dout;
    wire [15:0] write_data;
    wire [1:0] mem_cmd;

    // AND gate for write input to RAM
    assign write = (mem_cmd == `MWRITE) && (!mem_addr[8]);

    // Read-Write Memory from slide set 11
    RAM #(16, 8, "data.txt") MEM(clk, mem_addr[7:0], mem_addr[7:0], write, write_data, dout);

    wire [15:0] read_data;

    //tri-state driver for read_data and LDR instruction
    assign read_data = ((!mem_addr[8]) && (mem_cmd == `MREAD)) ? dout :
        ((mem_cmd == `MREAD) && (mem_addr == 9'h140)) ? {8'h00, SW[7:0]} : {16{1'bz}};

    // Setting load for LED's for STR instruction 
    wire load_ledr;
    assign load_ledr = (mem_cmd == `MWRITE) && (mem_addr == 9'h100);

    // LED load enabled register
    vDFFE9 #(8) REGLED(clk, load_ledr, write_data[7:0], LEDR[7:0]);

    wire Z, N, V;
    // instatntiate CPU
    cpu CPU( .clk   (clk), // recall from Lab 4 that KEY0 is 1 when NOT pushed
        .reset (~KEY[1]), 
        .read_data    (read_data),
        .mem_cmd (mem_cmd),
        .mem_addr (mem_addr),
        .write_data (write_data),
        .Z     (Z),
        .N     (N),
        .V     (V),
        .w     (LEDR[9])
    );

    assign HEX5[0] = ~Z; // TOP
    assign HEX5[6] = ~N; // MID
    assign HEX5[3] = ~V; // BOT

    // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
    sseg H0(write_data[3:0],   HEX0);
    sseg H1(write_data[7:4],   HEX1);
    sseg H2(write_data[11:8],  HEX2);
    sseg H3(write_data[15:12], HEX3);
    assign HEX4 = 7'b1111111; // disabled
    assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
    assign LEDR[8] = 1'b0; // disabled
endmodule

// To ensure Quartus uses the embedded MLAB memory blocks inside the Cyclone
// V on your DE1-SoC we follow the coding style from in Altera's Quartus II
// Handbook (QII5V1 2015.05.04) in Chapter 12, “Recommended HDL Coding Style”
//
// 1. "Example 12-11: Verilog Single Clock Simple Dual-Port Synchronous RAM 
//     with Old Data Read-During-Write Behavior" 
// 2. "Example 12-29: Verilog HDL RAM Initialized with the readmemb Command"

module RAM(clk,read_address,write_address,write,din,dout);
    parameter data_width = 32; 
    parameter addr_width = 4;
    parameter filename = "data.txt";

    input clk;
    input [addr_width-1:0] read_address, write_address;
    input write;
    input [data_width-1:0] din;
    output [data_width-1:0] dout;
    reg [data_width-1:0] dout;

    reg [data_width-1:0] mem [2**addr_width-1:0];

    initial $readmemb(filename, mem);

    always @ (posedge clk) begin
        if (write)
            mem[write_address] <= din;
        dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                                    // (this is due to Verilog non-blocking assignment "<=")
    end 
endmodule


// Register with load enabled
module vDFFE9(clk, en, in, out) ;
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


// The sseg module below can be used to display the value of datpath_out on
// the hex LEDS the input is a 4-bit value representing numbers between 0 and
// 15 the output is a 7-bit value that will print a hexadecimal digit.  You
// may want to look at the code in Figure 7.20 and 7.21 in Dally but note this
// code will not work with the DE1-SoC because the order of segments used in
// the book is not the same as on the DE1-SoC (see comments below).

module sseg(in,segs);
    input [3:0] in;
    output [6:0] segs;
    reg [6:0] segs;

    // NOTE: The code for sseg below is not complete: You can use your code from
    // Lab4 to fill this in or code from someone else's Lab4.  
    //
    // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
    // segment display you *need* to state the following three things in
    // a file README.txt that you submit with handin along with this code: 
    //
    //   1.  First and last name of student providing code
    //   2.  Student number of student providing code
    //   3.  Date and time that student provided you their code
    //
    // You must also (obviously!) have the other student's permission to use
    // their code.
    //
    // To do otherwise is considered plagiarism.
    //
    // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
    // the input bit is 0. Bits 6543210 correspond to:
    //
    //    0000
    //   5    1
    //   5    1
    //    6666
    //   4    2
    //   4    2
    //    3333
    //
    // Decimal value | Hexadecimal symbol to render on (one) HEX display
    //             0 | 0
    //             1 | 1
    //             2 | 2
    //             3 | 3
    //             4 | 4
    //             5 | 5
    //             6 | 6
    //             7 | 7
    //             8 | 8
    //             9 | 9
    //            10 | A
    //            11 | b
    //            12 | C
    //            13 | d
    //            14 | E
    //            15 | F

    always_comb begin
        case (in)
            4'b0000: segs = 7'b1000000;//0
            4'b0001: segs = 7'b1111001;//1
            4'b0010: segs = 7'b0100100;//2
            4'b0011: segs = 7'b0110000;//3
            4'b0100: segs = 7'b0011001;//4
            4'b0101: segs = 7'b0010010;//5
            4'b0110: segs = 7'b0000010;//6
            4'b0111: segs = 7'b1111000;//7
            4'b1000: segs = 7'b0000000;//8
            4'b1001: segs = 7'b0010000;//9

            4'b1010: segs = 7'b0001000;//A
            4'b1011: segs = 7'b0000011;//b
            4'b1100: segs = 7'b1000110;//C
            4'b1101: segs = 7'b0100001;//d
            4'b1110: segs = 7'b0000110;//E
            4'b1111: segs = 7'b0001110;//F
            default: segs = 7'bxxxxxxx;
        endcase
    end
endmodule
