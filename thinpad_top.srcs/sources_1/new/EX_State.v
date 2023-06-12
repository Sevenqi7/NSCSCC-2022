`timescale 1ns / 1ps
`include "InstrType.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/02 18:46:40
// Design Name: 
// Module Name: EX_State
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


module EX_State(
    input clk,
    input rst_n,
    input [31:0] ID_PC,
    input [31:0] ID_Instr,
    input [`InstrNum-1:0] ID_OptBus,

    input [4:0] ID_RsID,
    input [4:0] ID_RtID,
    input [4:0] ID_RdID,
    
    input [31:0] ID_RtData,
    input [31:0] ID_RsData,
    input [4:0] ID_shamt,
    input [15:0] ID_Imm16,
    input [31:0] ID_ExtImm32,
    
    input ID_RegWriteEn,
    input [1:0] ID_MemWriteEn,
    input [1:0] ID_MemReadEn,
    input ID_MemtoReg,

    input WB_RegWriteEn, 
    input [4:0] WB_RegWriteID,
    input [31:0] WB_RegWriteData,

    output reg [31:0] EX_PC,
    output reg [31:0] EX_Instr,
    output reg [31:0] EX_ALUOut,
    output reg [31:0] EX_MemWriteData,
    output reg [4:0] EX_RegWriteID,
    output reg EX_RegWriteEn,
    output reg [1:0] EX_MemWriteEn,
    output reg [1:0] EX_MemReadEn,
    output reg EX_MemtoReg,

    ////////////////////////
    output [3:0] EX_base_ram_be_n
    );

    wire [1:0] RegDst;
    wire [31:0] ALU_Data_1, ALU_Data_2, ALU_Out_temp;
    wire [31:0] ALU_Data_1_tmp = ALU_Data_1, 
                ALU_Data_2_tmp = ALU_Data_2;
    wire [31:0] MemWriteData;
    reg EX_isOptSWorLW, EX_isOptSBorLB;
    wire JAL_Type = ID_OptBus[4] || ID_OptBus[6];

    assign EX_base_ram_be_n = (!EX_isOptSWorLW && !EX_isOptSBorLB) ? 4'b0 :
                              EX_isOptSWorLW ? 4'b0 :
                              (EX_ALUOut[1:0] == 2'b00) ? 4'b1110 :
                              (EX_ALUOut[1:0] == 2'b01) ? 4'b1101 :
                              (EX_ALUOut[1:0] == 2'b10) ? 4'b1011 :
                              (EX_ALUOut[1:0] == 2'b11) ? 4'b0111 :
                              4'b0;

    ALUCtrl ALUCtrl(
        .ID_RsID(ID_RsID),
        .ID_RtID(ID_RtID),
        .ID_RdID(ID_RdID),
        .ID_RsData(ID_RsData),
        .ID_RtData(ID_RtData),
        .ID_shamt(ID_shamt),
        .ID_ExtImm32(ID_ExtImm32),
        .MEM_MemWriteAddr(EX_ALUOut),       //EX_ALUOut总是存放着上一条指令的ALU运算结果，因此实质上EX_ALUOut已经在MEM级
        .MEM_RegWriteID(EX_RegWriteID),    
        .MEM_RegWriteEn(EX_RegWriteEn),
        .WB_RegWriteEn(WB_RegWriteEn),      //这里不一样，WB开头的变量都是wire类型，因此直接用
        .WB_RegWriteID(WB_RegWriteID),
        .WB_RegWriteData(WB_RegWriteData),
        .OptBus(ID_OptBus),
        .RegDst(RegDst),
        .ALU_Data_1(ALU_Data_1),
        .ALU_Data_2(ALU_Data_2),
        .MemWriteData(MemWriteData)
        );
    
    ALU ALU(
        .ALU_Data_1(ALU_Data_1_tmp), 
        .ALU_Data_2(ALU_Data_2_tmp), 
        .OptBus(ID_OptBus),
        .Imm16(ID_Imm16),
        .ALU_Out(ALU_Out_temp)
        );

    always@(posedge clk) begin
        if(rst_n) begin
            EX_PC <= 0;
            EX_Instr <= 0;
            EX_ALUOut <= 0;
            EX_MemWriteEn <= 0;
            EX_MemReadEn <= 0;
            EX_RegWriteEn <= 0;
            EX_RegWriteID <= 0;
            EX_isOptSBorLB <= 0;
            EX_isOptSWorLW <= 0;
        end
        else begin
            EX_PC <= ID_PC;
            EX_Instr <= ID_Instr;
            EX_ALUOut <= !JAL_Type ? ALU_Out_temp : ID_PC+8;
            EX_MemtoReg <= ID_MemtoReg;
            EX_MemReadEn <= ID_MemReadEn;
            EX_MemWriteEn <= ID_MemWriteEn;
            // EX_MemWriteData <= MemWriteData;

            EX_MemWriteData <=  ((ID_MemWriteEn == 2'b10) ? MemWriteData :
                                (ID_MemWriteEn == 2'b01) ? {{24{MemWriteData[7]}}, MemWriteData[7:0]} :
                                32'h7777) << (8*ALU_Out_temp[1:0]);

            EX_RegWriteEn <= ID_RegWriteEn;
            EX_RegWriteID <= (RegDst == 2'b00) ? ID_RdID :
                             (RegDst == 2'b01) ? ID_RtID :
                             (RegDst == 2'b10) ? 5'b11111 :       //31号寄存器
                             4'o77;

            EX_isOptSBorLB <= ID_OptBus[1] || ID_OptBus[3];
            EX_isOptSWorLW <= ID_OptBus[0] || ID_OptBus[2];
        end
    end


endmodule
