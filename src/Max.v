`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/15 13:56:38
// Design Name: 
// Module Name: Max
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


module Max#(
    parameter BITWIDTH = 8,
    parameter LENGTH = 4
    )
    (
    //input: BITWIDTH(一個數字含有BITWIDTH個bits) * Pool_Size。
    //output: 在該Pool中最大的數字。
    input [BITWIDTH * LENGTH - 1 : 0] data,
    output reg signed [BITWIDTH - 1 : 0] result
    );
    
    wire signed [BITWIDTH - 1:0] dataArray[0:LENGTH - 1];
    genvar i;
    
    // 將input的所有數字賦值到一個dataArray方便處理。
    generate      
        for(i = 0; i < LENGTH; i = i + 1) begin
            assign dataArray[i] = data[i * BITWIDTH + BITWIDTH - 1: i * BITWIDTH];
        end
    endgenerate
    
    // 簡單的for loop 找最大值。
    integer j;
    always @(*) begin
        result = -127;
        for(j = 0; j < LENGTH; j = j + 1) begin
            if(dataArray[j] > result) begin
                result = dataArray[j];
            end
        end
    end
    
endmodule
