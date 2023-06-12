`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/07 22:19:28
// Design Name: 
// Module Name: MEM_State
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


module MEM_State(
    input clk,
    input rst_n,
    input [31:0] EX_PC,
    input [31:0] EX_Instr,
    input [31:0] DataMemOut,
    
    input [31:0] EX_ALUOut,
     input [31:0] EX_MemWriteData,
    input [4:0] EX_RegWriteID,
    input EX_RegWriteEn,
    // input [1:0] EX_MemWriteEn,
    input [1:0] EX_MemReadEn,
    input EX_MemtoReg,
    input [3:0] EX_base_ram_be_n,
    input is_using_uart,

    output reg [31:0] MEM_PC,
    output reg [31:0] MEM_Instr,
    output reg [31:0] MEM_MemtoRegData,       //从数据存储器中读取并要放到寄存器中的数据
    output reg [31:0] MEM_MemWriteAddr,       //sw或sb指令中的地址值
    output reg [31:0] MEM_MemWriteData,       //sw或sb指令中要存储到内存中的数据（加入SRAM后在thinpadtop内直接使用EX_MemWriteData）
    output reg [4:0] MEM_RegWriteID,
    output reg MEM_RegWriteEn,
    output reg MEM_MemtoReg
    );


    // DataMem DataMem(
    //     .clk(clk),
    //     .Addr(EX_ALUOut),
    //     .WriteData(EX_MemWriteData),
    //     .WriteEn(EX_MemWriteEn),
    //     .ReadEn(EX_MemReadEn),
    //     .DataOut(MemtoRegData),
    //     .tiaoshi(tiaoshi)
    // );

    

    always@(posedge clk) begin
        if(rst_n) begin
            MEM_PC <= 0;
            MEM_Instr <= 0;
            MEM_MemtoRegData <= 0;
            MEM_MemWriteAddr <= 0;
            MEM_MemWriteData <= 0;
            MEM_RegWriteEn <= 0;
            MEM_RegWriteID <= 0;
        end
        else begin
            MEM_PC <= EX_PC;
            MEM_Instr <= EX_Instr;
            MEM_MemtoRegData <= (EX_MemReadEn == 2'b10) ? DataMemOut :
                                (EX_MemReadEn == 2'b01) && is_using_uart ? DataMemOut :
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b1110) ? {{24{DataMemOut[7]}}, DataMemOut[7:0]} : 
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b1101) ? {{24{DataMemOut[15]}}, DataMemOut[15:8]} :
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b1011) ? {{24{DataMemOut[23]}}, DataMemOut[23:16]} :
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b0111) ? {{24{DataMemOut[31]}}, DataMemOut[31:24]} :
                                32'h7777;
            MEM_MemWriteAddr <= EX_ALUOut;
            MEM_MemWriteData <= EX_MemWriteData;
            MEM_RegWriteID <= EX_RegWriteID;
            MEM_RegWriteEn <= EX_RegWriteEn;
            MEM_MemtoReg <= EX_MemtoReg;
        end
    end

endmodule
