module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    // fill out the rest

    reg [15:0] sout;

    // Shift input depending on shift value
    always_comb begin
        case (shift)
            2'b00: sout = in; // copy input
            2'b01: sout = in << 1; // shift input 1bit left
            2'b10: sout = in >> 1; // shift input 1bit right
            2'b11: sout = {in[15], in[15:1]}; // shift input right, MSB is copy of in[15]
            default: sout = {16{1'bx}};
        endcase
    end
endmodule
