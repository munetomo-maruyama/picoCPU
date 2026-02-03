//===========================================================
// picoCPU Project
//-----------------------------------------------------------
// File Name   : tb.sv
// Description : Testbench for picoCPU System
//-----------------------------------------------------------
// History :
// Rev.01 2026.02.02 M.Maruyama First Release
//-----------------------------------------------------------
// Copyright (C) 2026 M.Maruyama
//===========================================================

`timescale 1ns/10ps

`define TB_CYCLE           100 //ns
`define TB_FINISH_COUNT  10000 //cyc

//------------------
// Top of Test Bench
//------------------
module tb();

//-----------------------------
// Generate Wave File to Check
//-----------------------------
initial
begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
end

//-------------------------------
// Generate Clock
//-------------------------------
logic clk;
//
initial clk = 1'b0;
always #(`TB_CYCLE / 2) clk = ~clk;

//--------------------------
// Generate Reset
//--------------------------
logic res;
//
initial
begin
    res = 1'b1;
        # (`TB_CYCLE * 10)
    res = 1'b0;       
end

//----------------------
// Cycle Counter
//----------------------
logic [31:0] tb_cycle_counter;
//
always_ff @(posedge clk, posedge res)
begin
    if (res)
        tb_cycle_counter <= 32'h0;
    else
        tb_cycle_counter <= tb_cycle_counter + 32'h1;
end
//
initial
begin
    forever
    begin
        @(posedge clk);
        if (tb_cycle_counter == `TB_FINISH_COUNT)
        begin
            $display("***** SIMULATION TIMEOUT ***** at %d", tb_cycle_counter);
            $finish;
        end
    end
end


//---------------------
// DUT Top
//---------------------
logic [7:0] porti;
logic [7:0] porto;
//
TOP U_TOP
(
    .CLK    (clk),
    .RES    (res),
    //
    .PORTI  (porti),
    .PORTO  (porto)
);

//--------------------------
// Input Pattern (Stimulus)
//--------------------------
initial
begin
    // Wait for Reset Release
    porti = 8'hff;
    @(posedge clk);
    @(negedge res);
    @(posedge clk);
    // Start
    #(`TB_CYCLE * 100);
    porti = 8'h00;
    #(`TB_CYCLE * 500);
    porti = 8'hff;
    #(`TB_CYCLE * 100);
    porti = 8'h00;
    #(`TB_CYCLE * 500);
    // End of Stimulus
    $finish;
end

endmodule
//===========================================================
// End of File
//===========================================================


