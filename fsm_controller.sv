// *** states *** //
`define RST 5'b00000
`define IF1 5'b00001
`define IF2 5'b00010
`define UpdatePC 5'b00011

`define MovRn 5'b00100
`define LoadB 5'b00101
`define LoadCB 5'b00110
`define Write 5'b00111
`define LoadA 5'b01000
`define LoadC 5'b01001
`define Status 5'b01010

`define LoadCim5 5'b01011
`define LoadAddr 5'b01100
`define ReadMem 5'b01101
`define WriteMdata 5'b01110
`define LoadBRd 5'b01111
`define WriteMem 5'b10001

`define HALT 5'b10010

// *** mem_cmd *** //
`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

module FSMC (
        input clk, 
        input reset, 
        
        // inputs from instruction decoder
        input [2:0] opcode,
        input [1:0] op,

        // output to instruction register
        output reg load_ir,
        
        // output to instruction decoder
        output reg [2:0] nsel,

        // output to PC
        output reg load_pc,
        output reg reset_pc,

        // output to data address register
        output reg load_addr,

        output reg addr_sel,

        output reg [1:0] mem_cmd,
        
        // outputs to datapath
        output reg [1:0] vsel,
        output reg loada,
        output reg loadb,
        output reg asel,
        output reg bsel,
        output reg loadc,
        output reg loads,
        output reg write,
        
        // set to 1 if in reset state and waiting for s to be set to 1
        output reg w
    );

    reg [4:0] present_state;

    always_ff @(posedge clk) begin
        if (reset) begin
            present_state = `RST;

            nsel = 3'b000;
            vsel = 2'b00;
            loada = 1'b0;
            loadb = 1'b0;
            asel = 1'b0;
            bsel = 1'b0;
            loadc = 1'b0;
            loads = 1'b0;
            write = 1'b0;

            // new inputs from lab 7
            load_ir = 1'b0;
            
            load_pc = 1'b1;
            reset_pc = 1'b1;

            load_addr = 1'b0;
            addr_sel = 1'b0;
            mem_cmd = `MNONE;
        end else begin

            // switching states
            case (present_state)

                // Instruction fetch/PC states (replacing wait state from lab 6)
                `RST: present_state = `IF1; // Go to Instruction Fetch stage 1
                `IF1: present_state = `IF2; // Go to Instruction Fetch stage 2
                `IF2: present_state = `UpdatePC; // Go to PC update state
                `UpdatePC: if (opcode == 3'b110 && op == 2'b10) 
                        present_state = `MovRn; // MOV Rn, #<im8> state
                    else if (opcode == 3'b011 || opcode == 3'b100) 
                        present_state = `LoadA; // Load register A state
                    else if (opcode == 3'b111) 
                        present_state = `HALT; // HALT state
                    else 
                        present_state = `LoadB; // load B state


                // States from lab 6 with added branches
                `MovRn: present_state = `IF1; // back to instruction fetch state
                `LoadB: if (opcode == 3'b110 || (opcode == 3'b101 && op == 2'b11)) // MOV Rd, Rm {,<sh_op>} or MVN Rd, Rm state
                        present_state = `LoadCB; // reg b value -> reg c value state
                    else
                        present_state = `LoadA; // load A state
                `LoadCB: if (opcode == 3'b100)
                        present_state = `WriteMem; // write to memory state
                    else
                        present_state = `Write; // write to Rn state
                `Write: present_state = `IF1; // back to instruction fetch state
                `LoadA: if (op == 2'b01)
                        present_state = `Status; // CMP Rn, Rm {,<sh_op>}
                    else if (opcode == 3'b011 || opcode == 3'b100)
                        present_state = `LoadCim5; // load C = RegA + im5
                    else
                        present_state = `LoadC; // regular load C state
                `LoadC: present_state = `Write; // write to Rn state
                `Status: present_state = `IF1; // back to instruction fetch state


                // New states for LDR and STR
                `LoadCim5: present_state = `LoadAddr; // load data address state
                `LoadAddr: if (opcode == 3'b011)
                        present_state = `ReadMem; // read from memory state
                    else
                        present_state = `LoadBRd; // read contents of Rd state

                // LDR states
                `ReadMem: present_state = `WriteMdata; // write from memory to regfile state
                `WriteMdata: present_state = `IF1; // back to instruction fetch state

                // STR states
                `LoadBRd: present_state = `LoadCB; // reg b value -> reg c value state
                `WriteMem: present_state = `IF1; // back to instruction fetch state

                // HALT state
                `HALT: present_state = `HALT; // remain in halt state until reset

                default: present_state = 5'bxxxxx;
            endcase

            // changing outputs (inputs to datapath) based on state
            case (present_state)
                `RST: begin // set all inputs to default
                    nsel = 3'b000;
                    vsel = 2'b00;
                    loada = 1'b0;
                    loadb = 1'b0;
                    asel = 1'b0;
                    bsel = 1'b0;
                    loadc = 1'b0;
                    loads = 1'b0;
                    write = 1'b0;

                    // new inputs from lab 7
                    load_ir = 1'b0;
                    
                    load_pc = 1'b1;
                    reset_pc = 1'b1;

                    load_addr = 1'b0;
                    addr_sel = 1'b0;
                    mem_cmd = `MNONE;
                end
                `IF1: begin // Instruction Fetch 1 from lab handout
                    write = 1'b0;  // reset all inputs that were set from previous
                    nsel = 3'b000; // states that loop back to this one
                    vsel = 2'b00;  // ^
                    loads = 1'b0; // ^
                    reset_pc = 1'b0;
                    load_pc = 1'b0;

                    addr_sel = 1'b1;
                    mem_cmd = `MREAD;
                end
                `IF2: begin // Instruction Fetch 2 from lab handout
                    addr_sel = 1'b1;  // reset these in `UpdatePC
                    load_ir = 1'b1;   // ^
                    mem_cmd = `MREAD; // ^
                end
                `UpdatePC: begin // Update PC from lab handout
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    mem_cmd = `MNONE;

                    load_pc = 1'b1; // reset this in `HALT, `MovRn, `LoadA, `LoadB
                end
                `MovRn: begin // Write to Rn
                    load_pc = 1'b0;

                    write = 1'b1;  // will get reset in IF1
                    nsel = 3'b100; // ^
                    vsel = 2'b10;  // ^
                end
                `LoadB: begin // load register B
                    load_pc = 1'b0;

                    loadb = 1'b1; // reset these in `LoadCB and `LoadA
                    nsel = 3'b001; // ^
                end
                `LoadCB: begin // Copy register B to register C
                    loadb = 1'b0;
                    nsel = 3'b000;

                    loadc = 1'b1; // reset these in `Write and `WriteMem
                    asel = 1'b1; // ^
                end
                `Write: begin // Write to Rd
                    loadc = 1'b0;
                    asel = 1'b0;

                    write = 1'b1;  // will get reset in IF1
                    nsel = 3'b010; // ^
                    vsel = 2'b00;  // ^
                end
                `LoadA: begin // load register A
                    loadb = 1'b0;
                    nsel = 3'b000;
                    load_pc = 1'b0;

                    loada = 1'b1; // reset these in `LoadC, `Status, `LoadCim5
                    nsel = 3'b100; // ^
                end
                `LoadC: begin // load register C with operation performed on A & B
                    loada = 1'b0;
                    nsel = 3'b000;

                    loadc = 1'b1; // reset in `Write
                end
                `Status: begin // load status register
                    loada = 1'b0;
                    nsel = 3'b000;

                    loads = 1'b1; // reset in `IF1
                end


                // New states for LDR and STR
                `LoadCim5: begin // load register C with address
                    loada = 1'b0;
                    nsel = 3'b000;

                    bsel = 1'b1; // reset in `LoadAddr
                    loadc = 1'b1;// ^
                end
                `LoadAddr: begin // load Data Address register with lower 9 bits of datapath_out (write_data)
                    bsel = 1'b0;
                    loadc = 1'b0;

                    load_addr = 1'b1; // reset in `ReadMem and `LoadBRd
                end

                // LDR states
                `ReadMem: begin // read from memory
                    load_addr = 1'b0;

                    mem_cmd = `MREAD; // does not get reset in next state
                end
                `WriteMdata: begin // Write data from memory to Rd
                    mem_cmd = `MREAD;
                    vsel = 2'b11;     // reset in `IF1
                    write = 1'b1;     // ^
                    nsel = 3'b010;    // ^
                end

                // STR states
                `LoadBRd: begin // load register B with contents of Rd
                    load_addr = 1'b0;

                    loadb = 1'b1; // reset in `LoadCB
                    nsel = 3'b010;// ^
                end
                `WriteMem: begin // write to memory
                    loadc = 1'b0;
                    asel = 1'b0;

                    mem_cmd = `MWRITE; // reste in `IF1
                end

                // HALT state
                `HALT: begin
                    nsel = 3'b000; // ensure everything is set to 0
                    vsel = 2'b00;
                    loada = 1'b0;
                    loadb = 1'b0;
                    asel = 1'b0;
                    bsel = 1'b0;
                    loadc = 1'b0;
                    loads = 1'b0;
                    write = 1'b0;
                    load_ir = 1'b0;
                    load_pc = 1'b0;
                    reset_pc = 1'b0;
                    load_addr = 1'b0;
                    addr_sel = 1'b0;
                    mem_cmd = `MNONE;
                end
                default: begin
                    nsel = 3'bxxx;
                    vsel = 2'bxx;
                    loada = 1'bx;
                    loadb = 1'bx;
                    asel = 1'bx;
                    bsel = 1'bx;
                    loadc = 1'bx;
                    loads = 1'bx;
                    write = 1'bx;
                    load_ir = 1'bx;
                    load_pc = 1'bx;
                    reset_pc = 1'bx;
                    load_addr = 1'bx;
                    addr_sel = 1'bx;
                    mem_cmd = 2'bxx;
                end
            endcase
        end
    end

    // set w to 1 when in update PC state (state where instruction register is updated)
    assign w = (present_state == `RST || present_state == `IF1 || present_state == `IF2 || present_state == `UpdatePC);
endmodule
