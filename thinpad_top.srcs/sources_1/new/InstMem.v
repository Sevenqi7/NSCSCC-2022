`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/06 17:48:17
// Design Name: 
// Module Name: InstMem
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


module InstMem(
    input [31:0] addr,
    input rst_n,
    output [31:0] Instr
    );

    reg [7:0] inst_mem[1023:0];

    assign Instr = rst_n ? 32'b0 :
            {inst_mem[addr], inst_mem[addr+1], inst_mem[addr+2], inst_mem[addr+3]};
endmodule
