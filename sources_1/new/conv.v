`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.09.2024 20:05:16
// Design Name: 
// Module Name: conv
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


module conv(
input        i_clk,                 //
input [71:0] i_pixel_data,          // Input linr for module
input        i_pixel_data_valid,    //
output reg [7:0] o_convolved_data,      // Output port for module
output reg      o_convolved_data_valid //
);
integer i;  
reg [7:0]  kernel [8:0];
reg [15:0] multdata [8:0];
reg [15:0] sumdataint;
reg [15:0] sumdata;
reg sumdata_valid;
reg multdata_valid;
reg convolved_data_valid;
initial
begin
    for  (i=0;i<9;i=1+1)
    begin
        kernel[i] = 1;
    end
end 
always @(posedge i_clk)
begin
     for  (i=0;i<9;i=1+1)
     begin
    multdata[i] <= kernel[i]*i_pixel_data[i*8+:8];
    end
multdata_valid <= i_pixel_data;
end
always @(*)
begin
    sumdataint <= 0;
     for  (i=0;i<9;i=1+1)
     begin
    sumdataint <= sumdataint + multdata[i];
    end
end
always @(posedge i_clk)
begin
sumdata <= sumdataint;
sumdata_valid <= multdata_valid;
end
always @(posedge i_clk)
begin
o_convolved_data <= sumdata/9;
o_convolved_data_valid <= sumdata_valid;
end
endmodule
