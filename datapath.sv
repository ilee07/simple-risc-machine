module datapath (
        input clk, 

        // register operand fetch stage
        input [2:0] readnum,
        input [1:0] vsel,
        input loada,
        input loadb,

        // computation stage (sometimes called "execute")
        input [1:0] shift, 
        input asel,
        input bsel,
        input [1:0] ALUop, 
        input loadc,
        input loads,

        // set when "writing back" to register file
        input [2:0] writenum,
        input write,
        input [15:0] sximm8,
        input [15:0] sximm5,

        // outputs
        output [2:0] status_out,
        output [15:0] datapath_out,

        // for lab 7
        input [8:0] PC,
        input [15:0] mdata
    );

    // instantiate Register File
    wire [15:0] data_in, data_out;
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

    // instantiate ALU
    wire [2:0] status;
    wire [15:0] outALU, Ain, Bin;
    ALU ALU(Ain, Bin, ALUop, outALU, status);

    // instantiate Shifter
    wire [15:0] sout, outB;
    shifter SHIFTER(outB, shift, sout);

    // instantiate Register A
    wire [15:0] outA;
    vDFFE2 #(16) REGA(clk, loada, data_out, outA);

    // instantiate Register B
    vDFFE2 #(16) REGB(clk, loadb, data_out, outB);

    // instantiate Register C
    vDFFE2 #(16) REGC(clk, loadc, outALU, datapath_out);

    // instantiate A select MUX2
    MUX2 #(16) MUX2A({16{1'b0}}, outA, asel, Ain);

    // instantiate B select MUX2
    MUX2 #(16) MUX2B(sximm5, sout, bsel, Bin);

    // instantiate vsel MUX4
    MUX4 #(16) MUX4V(mdata, sximm8, {7'b0, PC}, datapath_out, vsel, data_in);

    // instantiate Status Register
    vDFFE2 #(3) STATUS(clk, loads, status, status_out);
endmodule

// Register with load enabled
module vDFFE2(clk, en, in, out) ;
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

// 4-input, k-bit multiplexer with binary select
module MUX4(a3, a2, a1, a0, select, out) ;
    parameter k = 1 ;
    input [k-1:0] a3, a2, a1, a0;  // inputs
    input [1:0] select; // binary select
    output[k-1:0] out;
    reg [k-1:0] out;
    
    // a3 = mdata
    // a2 = sximm8
    // a1 = {8'b0, PC}
    // a0 = C

    // select output based on input
    always_comb begin
        case(select) 
        2'b11: out = a3;
        2'b10: out = a2;
        2'b01: out = a1;
        2'b00: out = a0;
        default: out =  {k{1'bx}};
        endcase
    end
endmodule

// 2-input, k-bit multiplexer with binary select 
module MUX2(a1, a0, select, out) ;
    parameter k = 1 ;
    input [k-1:0] a1, a0;  // inputs
    input select; // binary select
    output[k-1:0] out;
    reg [k-1:0] out;
    
    // select output based on input
    always_comb begin
        case(select) 
        1'b1: out = a1;
        1'b0: out = a0;
        default: out =  {k{1'bx}};
        endcase
    end
endmodule
