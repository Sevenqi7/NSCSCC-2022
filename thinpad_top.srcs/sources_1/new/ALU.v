`timescale 1ns / 1ps
`include "InstrType.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/07 16:57:07
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] ALU_Data_1,
    input [31:0] ALU_Data_2,
    input [`InstrNum-1:0] OptBus,
    input [15:0] Imm16,

    output [31:0] ALU_Out
    );

    wire `OperationSet;
    wire addOverFlow, subOverFlow;

    wire [31:0] AddResult,      //加法结果
                SubResult,      //减法结果
                SlResult,       //逻辑左移结果
                SrResult,       //逻辑右移结果
                ASrResult,       //算术右移结果
                OrResult,       //或运算结果
                AndResult,      //与运算结果
                XorResult,      //异或运算结果     
                LuiResult;

    wire [63:0] MulResult;      //乘法结果

    assign {`OperationSet} = OptBus;

    assign {addOverflow, AddResult} = {ALU_Data_1[31], ALU_Data_1} + {ALU_Data_2[31], ALU_Data_2};
    assign {subOverflow, SubResult} = {ALU_Data_1[31], ALU_Data_1} - {ALU_Data_2[31], ALU_Data_2};
    assign SlResult = ALU_Data_2 << ALU_Data_1[4:0];
    assign UsrResult = ALU_Data_2 >> ALU_Data_1[4:0];
    assign ASrResult = $signed(ALU_Data_2) >>> ALU_Data_1[4:0];
    assign SrResult = ALU_Data_2 >> ALU_Data_1[4:0];
    assign OrResult = ALU_Data_1 | ALU_Data_2;
    assign AndResult = ALU_Data_1 & ALU_Data_2;
    assign XorResult = ALU_Data_1 ^ ALU_Data_2;
    assign LuiResult = Imm16 << 16;

    mult_gen_0 multer(
        .A(ALU_Data_1),
        .B(ALU_Data_2),
        .P(MulResult)
    );

    assign ALU_Out = (ADD || ADDI || ADDU || ADDIU || LB || LW || SB || SW) ? AddResult :
                     (SUB) ? SubResult :
                     (AND || ANDI) ? AndResult:
                     (OR || ORI ) ? OrResult :
                     (XOR || XORI) ? XorResult :
                     (SLLV || SLL ) ? SlResult :
                     (SRLV || SRL) ? SrResult :
                     (SRAV || SRA) ? ASrResult :
                     (LUI) ? LuiResult :
                     (MUL) ? MulResult :
                     (SLT) ? ($signed(ALU_Data_1) < $signed(ALU_Data_2)) :
                     32'o7777;  //调试

endmodule
