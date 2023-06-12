`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/02 17:51:18
// Design Name: 
// Module Name: CalNextPC
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


module CalNextPC(
    input [31:0] instruction,
    input [31:0] PC,
    input [31:0] RsData,
    input [31:0] RtData,
    input [4:0] RsID,
    input [4:0] RtID,

    input [31:0] WB_RegWriteData,   //分支跳转�?要用到已经在后续流水级的数据
    input [4:0] WB_RegWriteID,
    input WB_RegWriteEn,

    input [31:0] MEM_MemWriteAddr,         //MEM级中可能将要写到寄存器中的数据（实际上是EX_ALUOut，这里的MEM表示的是数据当前在MEM级内，�?�不是从MEM级出去的�?
    input [4:0] MEM_RegWriteID,             //实质上是EX_RegWriteID
    input MEM_RegWriteEn,                   //实质上EX_RegWriteEn

    output [31:0] nextPC
    );

    wire [5:0] op, funct;

    wire [15:0] Imm16;
    wire [25:0] Imm26;
    wire [31:0] RealRsData, RealRtData;     //把数据冒险�?�虑在内的，真实的Rs和Rt寄存器中的�??

    // assign RealRsData = (WB_RegWriteEn && (RsID == WB_RegWriteID) && RsID) ? WB_RegWriteData :
    //                     (MEM_RegWriteEn && (RsID == MEM_RegWriteID) && RsID) ? MEM_MemWriteAddr :
    //                     RsData;
    // assign RealRtData = (WB_RegWriteEn && (RtID == WB_RegWriteID) && RtID) ? WB_RegWriteData :
    //                     (MEM_RegWriteEn && (RtID == MEM_RegWriteID) && RtID) ? MEM_MemWriteAddr :
    //                     RtData;

    assign RealRsData = (MEM_RegWriteEn && (RsID == MEM_RegWriteID) && RsID) ? MEM_MemWriteAddr :
                        (WB_RegWriteEn && (RsID == WB_RegWriteID) && RsID) ? WB_RegWriteData :
                        RsData;
    assign RealRtData = (MEM_RegWriteEn && (RtID == MEM_RegWriteID) && RtID) ? MEM_MemWriteAddr :
                        (WB_RegWriteEn && (RtID == WB_RegWriteID) && RtID) ? WB_RegWriteData :
                        RtData;

    assign Imm16 = instruction[15:0];
    assign Imm26 = instruction[25:0];
    assign Ext_Imm32 = {{14{Imm16}}, Imm16, 2'b00};
    assign op = instruction[31:26];
    assign funct = instruction[5:0];

    wire
        JR = ((op == 6'b000000) && (funct == 6'b001000)), 
        JALR = ((op == 6'b000000) && (funct == 6'b001001));

    wire         
        BEQ = (op == 6'b000100), 
        BNE = (op == 6'b000101), 
        BGEZ = (op == 6'b000001), 
        BGTZ = (op == 6'b000111), 
        BLEZ = (op == 6'b000110), 
        BLTZ = (op == 6'b000001);

    wire 
        J = (op == 6'b000010), 
        JAL = (op == 6'b000011);

    wire J_Type = J || JAL;

    wire JR_Type = JR || JALR;

    wire BJ_Type = BEQ ? RealRsData == RealRtData:
                 BNE ? RealRsData != RealRtData:
                 BGEZ ? RealRsData >= 0:
                 BGTZ ? RealRsData > 0:
                 BLEZ ? RealRsData[31] || RealRsData == 32'b0:
                 BLTZ ? RealRsData[31]:
                 0;

    wire [31:0] J_Addr = {PC[31:28], {Imm26, 2'b00}};
    wire [31:0] JR_Addr = RealRsData;
    wire [31:0] BJ_Addr = PC + {{14{Imm16[15]}}, Imm16, 2'b00};

    assign nextPC = J_Type ? J_Addr :
                    JR_Type ? JR_Addr :
                    BJ_Type ? BJ_Addr :
                    PC+4;

endmodule
