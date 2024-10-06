`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2024 08:07:15
// Design Name: 
// Module Name: lineBuf
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


module linbuff(
input i_clk,            //Clock
input i_rst,            // Reset 
input [7:0] i_data,             // One pixel value 8bit.
input i_data_valid,    // Data validation check
input i_rd_data,         // data read signal
output [23:0] o_data      //kernel size '3' data length 8bit for '5' kernel size it will '39:0'
);
reg [7:0] line [511:0];    // 8bit pixcel with 512 pixels
reg [8:0] wrPntr;           // log base '2' of the line number -- 512
reg [8:0] rdPntr; 
always @(posedge i_clk)            // the i_data is put in line register at +ve edge of input clock (i_clk
begin                              //
    if(i_data_valid)               // only valid data will be kept in regisster
        line[wrPntr] <= i_data;        //
end
always @(posedge i_clk)                         //
begin                                   //
    if(i_rst)                           //
         wrPntr <= 'd0;                 //  Write pointer
    else if(i_data_valid)               //
         wrPntr <= wrPntr + 'd1;        //
end                                     //
assign o_data = {line[rdPntr],line[rdPntr+1],line[rdPntr+2]}; // output data 3 pixels
always @(posedge i_clk)                         //
begin                                   //
    if(i_rst)                           //
         rdPntr <= 'd0;                 // Read pointer
    else if(i_rd_data)                  //
         rdPntr <= rdPntr + 'd1;        //
end
endmodule
 