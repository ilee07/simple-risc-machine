module ALU(Ain,Bin,ALUop,out,status);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output [2:0] status;
    // fill out the rest
    reg [15:0] out;
    reg [2:0] status;
    
    // ALU: performs operation based on ALUop and assigns out accordingly
    always_comb begin
        case (ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            default: out = 16'bx;
        endcase
    end

    // set status flag when ALUop is 2'b01
    assign status[0] = (ALUop == 2'b01) && (out == {16{1'b0}}); // Z flag
    assign status[1] = (ALUop == 2'b01) && (Ain[15] !== Bin[15]) && (out[15] != Ain[15]); // V flag
    assign status[2] = (ALUop == 2'b01) && out[15]; // N flag
endmodule
