`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/27 20:46:30
// Design Name: 
// Module Name: UART
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


module UART(
    input clk,
    input rst_n,
    input txd,
    input [31:0] Addr,
    input [7:0] Data_In,
    input [1:0] MemWriteEn,
    input [1:0] MemReadEn,
    output rxd,
    output [7:0] Data_Out
    );
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_busy;
reg ext_uart_start, ext_uart_avai, ext_uart_clear;

assign Data_Out = (Addr == 32'hBFD003F8) ? ext_uart_buffer :
                  (Addr == 32'hBFD003FC) ? {6'b0, ext_uart_ready, !ext_uart_busy} :
                  8'hAA;    //debug


async_receiver #(.ClkFrequency(50000000),.Baud(9600)) 
    ext_uart_r(
        .clk(clk),                     
        .rst_n(rst_n),
        .RxD(rxd),                           //rxd
        .RxD_data_ready(ext_uart_ready),  //数据接收到的标志
        .RxD_clear(ext_uart_clear),       //数据清除的标志
        .RxD_data(ext_uart_rx)             //接收数据
    );


always @(posedge clk) begin         //数据接收完毕时，存到buffer里
    if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
    end 
end
always @(*) begin                   //
    if(ext_uart_ready && MemReadEn && Addr ==32'hBFD003F8)begin 
        ext_uart_clear = 1;
    end else begin
        ext_uart_clear = 0;
    end
end
always @(posedge clk) begin         //
    if(!ext_uart_busy && MemWriteEn && Addr ==32'hBFD003F8)begin  //通过串口发送数据
        ext_uart_tx <= Data_In;//发送一个字节
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600))    
    ext_uart_t(
        .clk(clk),                  
        .TxD(txd),                      //txd
        .TxD_busy(ext_uart_busy),       //发送忙标志
        .TxD_start(ext_uart_start),     //开始发送的标志
        .TxD_data(ext_uart_tx)          //发送的数据
    );


endmodule
