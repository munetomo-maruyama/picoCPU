//===========================================================
// picoCPU Project
//-----------------------------------------------------------
// File Name   : top.sv
// Description : Top Layer
//-----------------------------------------------------------
// History :
// Rev.01 2026.02.02 M.Maruyama First Release
//-----------------------------------------------------------
// Copyright (C) 2026 M.Maruyama
//===========================================================


//========================================
// TOP
//========================================
module TOP
(
    input  logic CLK,
    input  logic RES,
    //
    input  logic [7:0] PORTI,
    output logic [7:0] PORTO
);

//-------------------------------
// Internal Signals
//-------------------------------
logic [5:0] addr;
logic       re;
logic       we;
logic [7:0] wdata;
logic [7:0] rdata;
    
//-------------------------------
// CPU
//-------------------------------
CPU U_CPU
(
    .CLK (CLK),
    .RES (RES),
    //
    .ADDR  (addr),
    .RE    (re),
    .WE    (we),
    .WDATA (wdata),
    .RDATA (rdata)
);

//-------------------------------
// Memory and Port
//-------------------------------
MEM U_MEM
(
    .CLK (CLK),
    .RES (RES),
    //
    .ADDR  (addr),
    .RE    (re),
    .WE    (we),
    .WDATA (wdata),
    .RDATA (rdata),
    //
    .PORTI (PORTI),
    .PORTO (PORTO)
);

endmodule
//===========================================================
// End of File
//===========================================================
