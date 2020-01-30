`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/15 14:29:19
// Design Name: 
// Module Name: Max_pool
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


module Max_pool#(
    parameter integer BITWIDTH = 8,
    
    parameter integer DATAWIDTH = 28,
    parameter integer DATAHEIGHT = 28,
    parameter integer DATACHANNEL = 3,
    
    //Pool_Size
    parameter integer KWIDTH = 2,
    parameter integer KHEIGHT = 2
    )
    (
    //input clk,
    //input clken,
    //input: 某個Map，包含長寬深(分別是這邊的DATAWIDTH、DATAHEIGHT、DATACHANNEL)。
    //output: 某個Map經過Pooling的結果，size = Map_size / Pool_Size
    input [BITWIDTH * DATAWIDTH * DATAHEIGHT * DATACHANNEL - 1 : 0]data,
    output reg [BITWIDTH * DATAWIDTH / KWIDTH * DATAHEIGHT / KHEIGHT * DATACHANNEL - 1 : 0] result
    );
    
    //每一個dataArray的element的size是BITWIDTH。
    //每一個paramArray的element的size是BITWIDTH * KHEIGHT * KWIDTH。
    wire [BITWIDTH - 1 : 0] dataArray[0 : DATACHANNEL - 1][0 : DATAHEIGHT-1][0 : DATAWIDTH - 1];
    wire [BITWIDTH * KHEIGHT * KWIDTH - 1 : 0]paramArray [0: DATACHANNEL - 1][0: DATAHEIGHT / KHEIGHT - 1][0: DATAWIDTH / KWIDTH - 1];
    
    //wire [BITWIDTH * DATAWIDTH / KWIDTH * DATAHEIGHT / KHEIGHT * DATACHANNEL - 1 : 0] out;
    
    //單純賦值，將input的所有數字賦值到一個dataArray方便處理。
    genvar i, j, k, m, n;
    generate       
        for(i = 0; i < DATACHANNEL; i = i + 1) begin
            for(j = 0; j < DATAHEIGHT; j = j + 1) begin
                for(k = 0; k < DATAWIDTH; k = k + 1) begin
                    assign dataArray[i][j][k] = data[(i * DATAHEIGHT * DATAWIDTH + j * DATAHEIGHT + k) * BITWIDTH + BITWIDTH - 1:(i * DATAHEIGHT * DATAWIDTH + j * DATAHEIGHT + k) * BITWIDTH];
                end
            end
        end      
    endgenerate
    
    //((m - j * 2) * KWIDTH + n - k * 2) * BITWIDTH + BITWIDTH - 1 是 Highest bit。
    //((m - j * 2) * KWIDTH + n - k * 2) * BITWIDTH 是 Lowest bit。
    generate 
        for(i = 0; i < DATACHANNEL; i = i + 1) begin
            for(j = 0; j < DATAHEIGHT / KHEIGHT; j = j + 1) begin
                for(k = 0; k < DATAWIDTH / KWIDTH; k = k + 1) begin
                    for(m = j * 2; m < j * 2 + KHEIGHT; m = m + 1) begin //做KHEIGHT次
                        for(n = k * 2; n < k * 2 + KWIDTH; n = n + 1) begin //做KWIDTH次
                            assign paramArray[i][j][k][((m - j * 2) * KWIDTH + n - k * 2) * BITWIDTH + BITWIDTH - 1:((m - j * 2) * KWIDTH + n - k * 2) * BITWIDTH] = dataArray[i][m][n];
                        end
                    end                   
                end
            end
        end
    endgenerate
    
    //一個一個將paramArray的所有element[每一個element(element map)的size是BITWIDTH * KHEIGHT * KWIDTH]丟到MAX module，求出每一個element map的最大值。
    generate
        for(i = 0; i < DATACHANNEL; i = i + 1) begin
            for(j = 0; j < DATAHEIGHT / KHEIGHT; j = j + 1) begin
                for(k = 0; k < DATAWIDTH / KWIDTH; k = k + 1) begin
                    Max#(BITWIDTH, KHEIGHT * KWIDTH) max(paramArray[i][j][k], result[(i * DATAHEIGHT / KHEIGHT * DATAWIDTH / KWIDTH + j * DATAWIDTH / KWIDTH + k) * BITWIDTH + BITWIDTH - 1:(i * DATAHEIGHT / KHEIGHT * DATAWIDTH / KWIDTH + j * DATAWIDTH / KWIDTH + k) * BITWIDTH]);
                end
            end
        end
    endgenerate
    
    // always @(posedge clk) begin
    //     if(clken == 1) begin
    //         result = out;
    //     end
    // end
    
endmodule
