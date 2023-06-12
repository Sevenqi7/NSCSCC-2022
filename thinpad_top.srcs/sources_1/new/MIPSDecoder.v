`timescale 1ns / 1ps
`include "InstrType.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/01 18:34:28
// Design Name: 
// Module Name: CtrlUnit
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


module MIPSDecoder(
    input [31:0] instruction,
    output [4:0] RsID,
    output [4:0] RtID,
    output [4:0] RdID,
    output [4:0] shamt,

    output RegWriteEn,
    output [1:0] RegDst,        //00:Rd, 01:Rt, 10:31号寄存器
    output[1:0] MemWriteEn,
    output[1:0] MemReadEn,
    output [15:0] Imm16,
    output [25:0] Imm26,
    output [31:0] ExtImm32,
    output MemtoReg,
    output [`InstrNum-1:0] OptBus  //用于记录正在decode的指令的指令类型（如ADD,SUB,MUL）
    );

    wire [5:0] funct, op;

    assign funct = instruction[5:0];
    assign op = instruction[31:26];
    assign Imm16 = instruction[15:0];
    assign Imm26 = instruction[25:0];
    

    assign RsID = instruction[25:21];
    assign RtID = instruction[20:16];
    assign RdID = instruction[15:11];
    assign shamt = instruction[10:6];

    //比赛要求实现的指令（共34条）
    /*R-TYPE*/
    wire 
        ADD = ((op == 6'b000000) && (funct == 6'b100000)), 
        ADDU = ((op == 6'b000000) && (funct == 6'b100001)), 
        SUB = ((op == 6'b000000) && (funct == 6'b100010)), 
        SLT = ((op == 6'b000000) && (funct == 6'b101010)), 
        MUL = ((op == 6'b011100) && (funct == 6'b000010)), 
        AND = ((op == 6'b000000) && (funct == 6'b100100)), 
        OR = ((op == 6'b000000) && (funct == 6'b100101)), 
        XOR = ((op == 6'b000000) && (funct == 6'b100110)), 
        SLL = ((op == 6'b000000) && (funct == 6'b000000)), 
        SLLV = ((op == 6'b000000) && (funct == 6'b000100)), 
        SRA = ((op == 6'b000000) && (funct == 6'b000011)), 
        SRAV = ((op == 6'b000000) && (funct == 6'b000111)),
        SRL = ((op == 6'b000000) && (funct == 6'b000010)), 
        SRLV = ((op == 6'b000000) && (funct == 6'b000110)), 
        JR = ((op == 6'b000000) && (funct == 6'b001000)), 
        JALR = ((op == 6'b000000) && (funct == 6'b001001));
    /*I-TYPE*/
    wire 
        ADDI = (op == 6'b001000), 
        ADDIU = (op == 6'b001001),
        ANDI = (op == 6'b001100), 
        LUI = (op == 6'b001111), 
        ORI = (op == 6'b001101), 
        XORI = (op == 6'b001110), 
        BEQ = (op == 6'b000100), 
        BNE = (op == 6'b000101), 
        BGEZ = (op == 6'b000001) && (RtID), 
        BGTZ = (op == 6'b000111), 
        BLEZ = (op == 6'b000110), 
        BLTZ = (op == 6'b000001) && (!RtID);
    /*J-TYPE*/
    wire 
        J = (op == 6'b000010), 
        JAL = (op == 6'b000011);
    /*load&save*/
    wire 
        LW = (op == 6'b100011), 
        LB = (op == 6'b100000), 
        SW = (op == 6'b101011), 
        SB = (op == 6'b101000);
    /*空指令*/
    wire NOP = 32'b0;
    assign ExtImm32 = (ORI || XORI || ANDI) ? {16'b0, instruction[15:0]} : {{16{instruction[15]}}, instruction[15:0]};

    assign MemWriteEn = SW ? 2'b10 : SB ? 2'b01 : 2'b00;
    assign MemReadEn = LW ? 2'b10 : LB ? 2'b01 : 2'b00;
    assign RegWriteEn = !NOP && (ADD || ADDU || SUB || SLT ||
                        MUL || AND || OR || XOR || SLL || 
                        SLLV || SRA || SRAV || SRL ||
                        SRLV || JALR || ADDI || ADDIU ||
                        ANDI || LUI || ORI || XORI ||
                        LW || LB || JAL);
    assign RegDst = (ADD || ADDU || SUB || SLT ||
                    MUL || AND || OR || XOR || SLL ||
                    SLLV || SRA || SRAV || SRL || SRLV ||
                    (JALR && RdID)) ? 2'b00 
                    : (ADDI || ADDIU || ANDI || LUI ||
                    ORI || XORI) ? 2'b01
                    : JAL || (JALR && !RdID)? 2'b10 
                    : 2'b11;    //2'b11时行为未定义
    assign MemtoReg = (LW || LB);
    assign OptBus = {`OperationSet};
    
endmodule
