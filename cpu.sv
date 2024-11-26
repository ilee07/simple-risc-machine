module cpu(clk, reset, read_data, mem_cmd, mem_addr, write_data, N, V, Z, w);
    input clk, reset;
    input [15:0] read_data;
    output [1:0] mem_cmd;
    output [8:0] mem_addr;
    output [15:0] write_data;
    output N, V, Z, w;

    // instantiate instruction register
    wire [15:0] instruction;
    wire load_ir; // set by fsm
    vDFFE3 #(16) REGI(clk, load_ir, read_data, instruction);

    // instantiate instruction decoder
    wire [2:0] nsel;
    wire [2:0] opcode;
    wire [1:0] op;
    wire [1:0] ALUop;
    wire [15:0] sximm5;
    wire [15:0] sximm8;
    wire [1:0] shift;
    wire [2:0] readnum;
    wire [2:0] writenum;
    IDec IDEC(instruction, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

    // instantiate state machine
    wire [1:0] vsel;
    wire loada, loadb, loadc, loads;
    wire asel, bsel;
    wire write;

    wire load_addr;
    wire addr_sel;
    wire load_pc;
    wire reset_pc;
    FSMC FSMC(
        clk, reset,
        
        opcode, op, // inputs from instruction decoder
        
        load_ir, // output to instruction register

        nsel, // output to instruction decoder

        load_pc, reset_pc, // output to PC

        load_addr, // output to data address register

        addr_sel, 

        mem_cmd,
        
        vsel, loada, loadb, asel, bsel,
        loadc, loads, write, //outputs to datapath
        
        w // set to 1 if in reset state
    );

    // instantiate datapath
    wire [2:0] status_out;
    wire [8:0] PC;
    wire [15:0] mdata;
    datapath DP(
        clk,

        readnum, vsel, loada, loadb,
        
        shift, asel, bsel, ALUop, loadc, loads,
        
        writenum, write, sximm8, sximm5,

        status_out, write_data, // <-- datapath_out

        PC,
        read_data // <-- mdata
    );

    // N flag set to 1 if CMP instruction is negative
    assign N = status_out[2];

    // V flag set to 1 if overflow occured
    assign V = status_out[1];

    // Z flag set to 1 if output is 0
    assign Z = status_out[0];

    // instantiate data address register
    wire [8:0] da_out;
    vDFFE3 #(9) REGDA(clk, load_addr, write_data[8:0], da_out);

    // 2 input mux for mem_addr using addr_sel
    assign mem_addr = addr_sel ? PC : da_out;

    // instantiate PC register
    wire [8:0] next_pc;
    vDFFE3 #(9) REGPC(clk, load_pc, next_pc, PC);

    // instantiate mux and adder for PC
    assign next_pc = reset_pc ? 9'b0 : (PC + 1);
endmodule

// Register with load enabled
module vDFFE3(clk, en, in, out) ;
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

// Instruction decoder
module IDec(in, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] in;
    input [2:0] nsel;

    // to FSM
    output [2:0] opcode;
    output [1:0] op;

    // to datapath
    output [1:0] ALUop;
    output [15:0] sximm5;
    output [15:0] sximm8;
    output [1:0] shift;
    output reg [2:0] readnum;
    output reg [2:0] writenum;

    // inputs to controller FSM
    assign opcode = in[15:13]; // MOV or ALU instruction
    assign op = in[12:11]; // type of MOV instruction or type of ALU operation

    // inputs to datapath
    assign ALUop = in[12:11]; // controls type of ALU operation
    assign sximm5 = {{11{in[4]}}, in[4:0]}; // 16 bit sign extend of in[4:0]
    assign sximm8 = {{8{in[7]}}, in[7:0]}; // 16 bit sign extend of in[7:0]
    assign shift = in[4:3]; // controls type of shifter operation

    // 3 input multiplexer controlled by one hot select 'nsel'
    always_comb begin
        case(nsel) // Rd = Rn {operation} Rm
            3'b100: begin // Rn
                readnum = in[10:8];
                writenum = in[10:8];
            end
            3'b010: begin // Rd
                readnum = in[7:5];
                writenum = in[7:5];
            end
            3'b001: begin // Rm
                readnum = in[2:0];
                writenum = in[2:0];
            end
            default:begin
                readnum = {3{1'bx}};
                writenum = {3{1'bx}};
            end 
        endcase
    end
endmodule
