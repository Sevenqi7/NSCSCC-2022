`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/02 18:22:07
// Design Name: 
// Module Name: Register
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


module Register(
    input clk,
    input rst_n,
    input [4:0] RsID,
    input [4:0] RtID,
    input [4:0] RegWriteID,
    input [31:0] RegWriteData,
    input RegWriteEn,
    output [31:0] d_out1,
    output [31:0] d_out2
    );

    reg [31:0] Reg [31:0];      //MIPS通用寄存器定�?

    initial begin
        Reg[0] = 0;
    end

    assign d_out1 = (!RsID) ? 32'b0 :  //读寄存器号为0
                    (RsID == RegWriteID) ? RegWriteData :
                    Reg[RsID];

    assign d_out2 = (!RtID) ? 32'b0 :  //读寄存器号为0
                    (RtID == RegWriteID) ? RegWriteData :
                    Reg[RtID];                    

    integer i;
    always @(posedge clk) begin
        if(rst_n) begin
            for(i=0;i<32;i=i+1'b1)
                Reg[i] = 32'b0;
        end
        else begin
            if(RegWriteEn && RegWriteID != 0)
                Reg[RegWriteID] <= RegWriteData;
        end
    end

endmodule
