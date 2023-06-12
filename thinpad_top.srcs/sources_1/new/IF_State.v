`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/01 16:37:22
// Design Name: 
// Module Name: ID_State
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define StartAddr 32'h80000000

module IF_State(
    input clk,
    input rst_n,
    input ID_stall,
    input [31:0] Instr,
    input [31:0] ID_nextPC, //Decoder阶段算出的下一个PC值
    output [31:0] IF_PC_WIRE,
    output reg[31:0] IF_PC,
    output reg[31:0] IF_Instr,
    
    //////////////结合SRAM调试新增
    input IF_SRAM_stall
);
    reg [31:0] IF_nextPC;
    wire [31:0] nextPC;

    assign nextPC = ID_nextPC;
    assign IF_PC_WIRE = IF_nextPC;
    
//    InstMem InstrMem(.addr(IF_PC), .rst_n(rst_n), .Instr(Instr));     


    always @(posedge clk) begin
        if(rst_n) begin
            IF_nextPC <= `StartAddr;
            IF_PC <= 0;
            IF_Instr <= 0;
        end
        else if(ID_stall || IF_SRAM_stall) begin
            IF_PC <= IF_PC;
            IF_nextPC <= IF_nextPC;
            IF_Instr <= IF_Instr;
        end
        else begin
            IF_PC <= IF_nextPC;
            IF_nextPC <= nextPC;
            IF_Instr <= Instr;
        end
    end


endmodule
