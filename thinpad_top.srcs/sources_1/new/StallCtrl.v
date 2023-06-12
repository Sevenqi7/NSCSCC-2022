`timescale 1ns / 1ps
`include "InstrType.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/09 19:59:48
// Design Name: 
// Module Name: StallCtrl
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


module StallCtrl(
    input clk,
    input rst_n,
    input [`InstrNum-1:0] OptBus, 
    input EX_isOpt_LWorLB,
    input ID_isOpt_LWorLB,
    input ID_RegWriteEn,
    input EX_RegWriteEn,
    input [4:0] EX_RegWriteID,
    input [4:0] ID_RtID,
    input [4:0] ID_RdID,
    input [4:0] RsID,
    input [4:0] RtID,
    output stall         //阻塞信号
    );
/*
    出现下列情况时需要阻塞：
    1.LW或LB后第一条指令为比较型跳转指令（BJ_Op）或JR，且使用的寄存器数据相关：阻塞2个周期
    2.LW或LB后第二条指令为比较型跳转指令（BJ_Op）或JR，且使用的寄存器数据相关：阻塞1个周期
    3.LW或LB后第一条指令为其它类型的指令，且使用的寄存器数据相关：阻塞1个周期
    4.其它运算指令后第一条指令为比较型跳转指令（BJ_Op）或JR，且使用的寄存器数据相关，阻塞1个周期

    stall_cnt：当LW或LB后第一条指令为比较型跳转指令时在时钟上升沿置1。用于实现阻塞2个周期的目的。
*/

    reg[1:0] stall_cnt;
    wire `OperationSet, BJ_Op;

    wire stall_case_1 = (ID_isOpt_LWorLB && ((ID_RtID == RsID) || (ID_RtID == RtID))) || stall_cnt;
    wire stall_case_2 = (EX_isOpt_LWorLB && ((EX_RegWriteID == RsID) || (EX_RegWriteID == RtID)) && EX_RegWriteID);
    wire stall_case_3 = (ID_isOpt_LWorLB && ID_RegWriteEn && ((ID_RtID == RsID) || (ID_RtID == RtID)));
    wire stall_case_4 = (BJ_Op && ID_RegWriteEn && ((ID_RdID == RsID) || (ID_RdID == RsID) || (ID_RtID == RsID) || (ID_RtID == RtID)));

    
    assign {`OperationSet} = OptBus;

    assign BJ_Op = BEQ || BNE || BGEZ || BGTZ || BLEZ || BLTZ || JR;
    assign stall = stall_case_1 || stall_case_2 || stall_case_3 || stall_case_4;

    // assign stall = ((is_lastOp_LW && ((LastCircleRtID == RsID) || (LastCircleRtID == RtID))) ||  stall_cnt) 
                    // ||  (BJ_Op && ID_RegWriteEn && NeedStall);


    always@(posedge clk) begin
        if(rst_n)
            stall_cnt <= 0;
        else if(!stall_cnt && ID_isOpt_LWorLB && BJ_Op && ((ID_RtID == RsID) || (ID_RtID == RtID)))
            stall_cnt <= 1;
        else if(stall_cnt)
            stall_cnt <= stall_cnt - 1;
        else stall_cnt <= 0;
    end

endmodule
