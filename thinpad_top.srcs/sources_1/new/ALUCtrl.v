`timescale 1ns / 1ps
`include "InstrType.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/06 20:27:14
// Design Name: 
// Module Name: ALUCtrl
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


module ALUCtrl(
    input [4:0] ID_RsID,
    input [4:0] ID_RtID,
    input [4:0] ID_RdID,

    input [31:0] ID_RsData,
    input [31:0] ID_RtData,
    input [4:0] ID_shamt,
    input [31:0] ID_ExtImm32,

    input [31:0] MEM_MemWriteAddr,   
    input [4:0] MEM_RegWriteID,
    input  MEM_RegWriteEn,

    input WB_RegWriteEn,
    input [4:0] WB_RegWriteID,
    input [31:0] WB_RegWriteData,

    input [`InstrNum-1:0] OptBus,
           
    output reg [1:0] RegDst,            //00时目的寄存器为Rd，01时为Rt，11时为31号寄存器
    output [31:0] ALU_Data_1,           //ALU操作数1
    output [31:0] ALU_Data_2,            //ALU操作数2
    output [31:0] MemWriteData          //写入内存的数据
    );

    wire `OperationSet;

    reg [1:0] ALUSrc1;                  //00时ALU操作数1来自RsData，01时来自shamt，10时来自MEM级旁路，11时来自WB级旁路
    reg [1:0] ALUSrc2;                  //00时ALU操作数2来自RtData，01时来自ExtImm32，10时来自MEM级旁路，11时来自WB级旁路

    assign {`OperationSet} = OptBus;
    assign ALU_Data_1 = (ALUSrc1 == 2'b00) ? ID_RsData : 
                        (ALUSrc1 == 2'b01) ? {{27{1'b0}}, ID_shamt} :
                        (ALUSrc1 == 2'b10) ? MEM_MemWriteAddr :
                        WB_RegWriteData;

    assign ALU_Data_2 = (ALUSrc2 == 2'b00) ? ID_RtData : 
                        (ALUSrc2 == 2'b01) ? ID_ExtImm32 :
                        (ALUSrc2 == 2'b10) ? MEM_MemWriteAddr :
                        WB_RegWriteData;
    assign MemWriteData = (!SB && !SW) ? 32'b0 :
                        ((MEM_RegWriteEn) && (MEM_RegWriteID == ID_RtID) && MEM_RegWriteID) ? MEM_MemWriteAddr :
                        ((WB_RegWriteEn) && (WB_RegWriteID == ID_RtID) && WB_RegWriteID) ? WB_RegWriteData : 
                        ID_RtData;
    

    always@(*) begin
        ALUSrc1 <=  (SLL || SRA || SRL) ? 2'b01 :
                    ((MEM_RegWriteEn) && (MEM_RegWriteID == ID_RsID) && MEM_RegWriteID) ? 2'b10 :
                    ((WB_RegWriteEn) && (WB_RegWriteID == ID_RsID) && WB_RegWriteID) ? 2'b11 :
                    2'b00;
        ALUSrc2 <=  (ADDI || ADDIU || ANDI || LUI || ORI || XORI || LB || LW || SB || SW) ? 2'b01 :
                    ((MEM_RegWriteEn) && (MEM_RegWriteID == ID_RtID) && MEM_RegWriteID) ? 2'b10 :
                    ((WB_RegWriteEn) && (WB_RegWriteID == ID_RtID) && WB_RegWriteID) ? 2'b11 :
                    2'b00;            
        RegDst  <=  (ADD || ADDU || SUB || SLT || MUL || AND || OR || XOR || SLLV || SLL || SRAV || SRA || SRL || SRLV || (JALR && ID_RdID)) ? 2'b00:       //目的寄存器为Rd，共15条 
                    (ADDI || ADDIU || ANDI || LUI || ORI || XORI || LB || LW ) ? 2'b01 :         //目的寄存器为Rt，共8条
                    (JAL || (JALR && !ID_RdID)) ? 2'b10 :
                    2'b11;
    end

endmodule
