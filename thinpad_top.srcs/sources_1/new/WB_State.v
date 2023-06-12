`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/08 02:24:33
// Design Name: 
// Module Name: WB_State
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


module WB_State(
    // input clk,
    // input rst_n,
    // input [31:0] MEM_PC,
    // input [31:0] MEM_Instr,
    input [31:0] MEM_MemtoRegData,
    input [31:0] MEM_RegWriteData,      //与MEM_MemWriteAddr一样
    input [4:0] MEM_RegWriteID,
    input MEM_MemtoReg, MEM_RegWriteEn,
    
    output wire WB_RegWriteEn,
    output wire [4:0] WB_RegWriteID,
    output wire [31:0] WB_RegWriteData
    );

    assign WB_RegWriteData = MEM_MemtoReg ? MEM_MemtoRegData : MEM_RegWriteData;
    assign WB_RegWriteID = MEM_RegWriteID;
    assign WB_RegWriteEn = MEM_RegWriteEn;



endmodule
