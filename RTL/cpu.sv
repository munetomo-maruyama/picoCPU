//===========================================================
// picoCPU Project
//-----------------------------------------------------------
// File Name   : cpu.sv
// Description : CPU Core
//-----------------------------------------------------------
// History :
// Rev.01 2026.02.02 M.Maruyama First Release
//-----------------------------------------------------------
// Copyright (C) 2026 M.Maruyama
//===========================================================

//-------------------------------------------------
// CPU Instruction
//-------------------------------------------------
// 00iiiiii  ADD #imm6    A<--A+#imm6
// 01aaaaaa  JNZ @addr6   if (A!=0) PC<--addr6
// 10aaaaaa  LDA @addr6   A<--@addr6
// 11aaaaaa  STA @addr6   @addr6<--A

//------------------------------
// Cotrol State
//------------------------------
`define STATE_INIT   3'h0
`define STATE_FETCH  3'h1
`define STATE_DECODE 3'h2
`define STATE_ADD    3'h3
`define STATE_JNZ    3'h4
`define STATE_LDA    3'h5
`define STATE_LDA2   3'h6
`define STATE_STA    3'h7

//========================================
// CPU
//========================================
module CPU
(
    input  logic CLK,
    input  logic RES,
    //
    output logic [5:0] ADDR,
    output logic       RE,
    output logic       WE,
    output logic [7:0] WDATA,
    input  logic [7:0] RDATA
);

//------------------------------------
// CPU Data Path : Instruction Code
//------------------------------------
logic [7:0] icode;     // Instruction Code
logic       icode_get; // Get icode
logic [1:0] opcode;    // Operation Code
//
assign opcode = RDATA[7:6];
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        icode <= 8'h00;
    else if (icode_get)
        icode <= RDATA;
end

//------------------------------------
// CPU Data Path : Program Counter
//------------------------------------
logic [5:0] pc;      // Program Counter
logic [5:0] pc_next; // Next PC
logic       pc_inc;  // Increment PC
logic       pc_jmp;  // Jump PC
//
assign pc_next = icode[5:0];
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        pc <= 6'h00;
    else if (pc_inc)
        pc <= pc + 6'h01;
    else if (pc_jmp)
        pc <= pc_next;
end

//------------------------------------
// CPU Data Path : Register A
//------------------------------------
logic [7:0] regA;     // Register A
logic       regA_ld;  // Load to A
logic       regA_add; // Add to A
logic       regA_nz;  // A is Not Zero
logic [7:0] imm;      // Immediate Data
//
assign imm = {icode[5], icode[5], icode[5:0]};
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        regA <= 8'h00;
    else if (regA_ld)
        regA <= RDATA;
    else if (regA_add)
        regA <= regA + imm;
end
//
assign regA_nz = |regA;

//------------------------------------
// CPU Data Parh : Memory Access
//------------------------------------
logic addr_pc;
logic addr_rw;
//
assign ADDR = (addr_pc)? pc
            : (addr_rw)? icode[5:0]
            : 6'h00;
assign WDATA = regA;

//------------------------------------
// CPU Control Logic
//------------------------------------
logic [2:0] state;
logic [2:0] state_next;
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        state <= `STATE_INIT;
    else
        state <= state_next;
end
//
always_comb
begin
    // Set Default Value
    icode_get = 1'b0;
    pc_inc    = 1'b0;
    pc_jmp    = 1'b0;
    regA_ld   = 1'b0;
    regA_add  = 1'b0;
    addr_pc   = 1'b0;
    addr_rw   = 1'b0;
    RE        = 1'b0;
    WE        = 1'b0;
    //
    case (state)
        //---------------------------------
        // Initial State
        `STATE_INIT:
        begin
            state_next = `STATE_FETCH;        
        end
        //---------------------------------
        // Instruction Fetch
        `STATE_FETCH:
        begin
            RE = 1'b1;
            addr_pc = 1'b1;
            state_next = `STATE_DECODE;
        end
        //---------------------------------
        // Instruction Decode
        `STATE_DECODE:
        begin
            icode_get = 1'b1;
                 if (opcode == 2'b00) state_next = `STATE_ADD;
            else if (opcode == 2'b01) state_next = `STATE_JNZ;
            else if (opcode == 2'b10) state_next = `STATE_LDA;
            else if (opcode == 2'b11) state_next = `STATE_STA;
            else state_next = `STATE_INIT; // never reach here
        end
        //---------------------------------
        // ADD
        `STATE_ADD:
        begin
            regA_add = 1'b1;
            pc_inc   = 1'b1;
            state_next = `STATE_FETCH;
        end
        //---------------------------------
        // JNZ
        `STATE_JNZ:
        begin
            pc_jmp =  regA_nz;
            pc_inc = ~regA_nz;
            state_next = `STATE_FETCH;
        end
        //---------------------------------
        // LDA
        `STATE_LDA:
        begin
            RE = 1'b1;
            addr_rw = 1'b1;
            state_next = `STATE_LDA2;
        end
        `STATE_LDA2:
        begin
            regA_ld = 1'b1;
            pc_inc   = 1'b1;
            state_next = `STATE_FETCH;
        end
        //---------------------------------
        // STA
        `STATE_STA:
        begin
            WE = 1'b1;
            addr_rw = 1'b1;
            pc_inc   = 1'b1;
            state_next = `STATE_FETCH;        
        end
        //---------------------------------
        // Default (NOP)
        default:
        begin
            pc_inc   = 1'b1;
            state_next = `STATE_FETCH;                
        end
    endcase
end

endmodule
//===========================================================
// End of File
//===========================================================
