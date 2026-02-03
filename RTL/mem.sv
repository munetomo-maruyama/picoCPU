//===========================================================
// picoCPU Project
//-----------------------------------------------------------
// File Name   : mem.sv
// Description : Memory and Port
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

//-------------------------------------------------
// Example Program blinkLED
//-------------------------------------------------
// ADDR CODE MNEMONIC
// 0x00 0xbe START   LDA  @PORTI
// 0x01 0x40         JNZ  @START
// 0x02 0xa1 INIT    LDA  @TEN
// 0x03 0x3f LOOP    ADD  #-1
// 0x04 0x43         JNZ  @LOOP
// 0x05 0xbf OUT     LDA  @POUT
// 0x06 0x01         ADD  #1
// 0x07 0xff         STA  @POUT
// 0x08 0xa0 RESTART LDA  @ONE
// 0x09 0x40         JNZ  @START
//
// 0x20 0x01 ONE     CONST 0x01
// 0x21 0x0a TEN     CONST 0X0a
//
// 0x3e 0x00 PORTI   DATA   0x00
// 0x3f 0x00 PORTO   DATA   0x00 

//========================================
// Memory with Port I/O
//========================================
module MEM
(
    input  logic CLK,
    input  logic RES,
    //
    input  logic [5:0] ADDR,
    input  logic       RE,
    input  logic       WE,
    input  logic [7:0] WDATA,
    output logic [7:0] RDATA,
    //
    input  logic [7:0] PORTI,
    output logic [7:0] PORTO
);

// Memory Mat
logic [7:0] mem[0:63];

// Initialize Memory
initial
begin
    mem[ 0]=8'hbe; mem[ 1]=8'h40; mem[ 2]=8'ha1; mem[ 3]=8'h3f; 
    mem[ 4]=8'h43; mem[ 5]=8'hbf; mem[ 6]=8'h01; mem[ 7]=8'hff; 
    mem[ 8]=8'ha0; mem[ 9]=8'h40;
    mem[32]=9'h01; mem[33]=8'h0a;
end

// Read Operation
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        RDATA <= 8'h00;
    else if (RE & (ADDR == 6'h3e))
        RDATA <= PORTI;      // PORT Input
    else if (RE & (ADDR == 6'h3f))
        RDATA <= PORTO;      // PORT Output
    else if (RE)
        RDATA <= mem[ADDR];  // Memory
end

// Write Operation
always_ff @(posedge CLK)
begin
    if (WE) mem[ADDR] <= WDATA; // Memory
end
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        PORTO <= 8'h00;
    else if (WE & (ADDR == 6'h3f))
        PORTO <= WDATA;        // Port Output
end

endmodule
//===========================================================
// End of File
//===========================================================
