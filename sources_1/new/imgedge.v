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


module imgedge(
input        i_clk,                 //
input [71:0] i_pixel_data,          // Input linr for module
input        i_pixel_data_valid,    //
output reg [7:0] o_convolved_data,      // Output port for module
output reg      o_convolved_data_valid //
);
integer i;  
reg [7:0]  kernelx [8:0];
reg [7:0]  kernely [8:0];
reg [10:0] multdatax [8:0];
reg [10:0] multdatay [8:0];
reg [10:0] sumdataintx;
reg [10:0] sumdatainty;
reg [10:0] sumdatax;
reg [10:0] sumdatay;
reg [20:0]convolveddatax;
reg [20:0]convolveddatay;
wire [21:0] convolved_sum;
reg sumdata_valid;
reg multdata_valid;
reg convolved_data_valid;
reg convolved_data_valid_int;

initial
begin
   kernelx[0] =  1;
   kernelx[1] =  0;
   kernelx[2] = -1;
   kernelx[3] =  2;
   kernelx[4] =  0;
   kernelx[5] = -2;
   kernelx[6] =  1;
   kernelx[7] =  0;
   kernelx[8] = -1;
   
   kernely[0] =  1;
   kernely[1] =  2;
   kernely[2] =  1;
   kernely[3] =  0;
   kernely[4] =  0;
   kernely[5] =  0;
   kernely[6] = -1;
   kernely[7] = -2;
   kernely[8] = -1;
end 
always @(posedge i_clk)
begin
     for  (i=0;i<9;i=1+1)
     begin
        multdatax[i] <= $signed(kernelx[i])*$signed({1'b0,i_pixel_data[i*8+:8]});
        multdatay[i] <= $signed(kernely[i])*$signed({1'b0,i_pixel_data[i*8+:8]});
    end
multdata_valid <= i_pixel_data;
end
always @(*)
begin
    sumdataintx <= 0;
    sumdatainty <= 0;
     for  (i=0;i<9;i=1+1)
     begin
        sumdataintx <= $signed(sumdataintx) + $signed(multdatax[i]);
        sumdatainty <= $signed(sumdatainty) + $signed(multdatay[i]);
    end
end
always @(posedge i_clk)
begin
    sumdatax <= sumdataintx;
    sumdatay <= sumdatainty;
    sumdata_valid <= multdata_valid;
end


always @(posedge i_clk)
begin
    convolveddatax <= $signed(sumdatax)*$signed(sumdatax);
    convolveddatay <= $signed(sumdatay)*$signed(sumdatay);
    convolved_data_valid_int <= sumdata_valid;
end

assign convolved_sum = convolveddatax + convolveddatay;

always @(posedge i_clk)
begin
if(convolved_sum > 1500)
o_convolved_data <= 8'hff;
else
o_convolved_data <= 8'h00;
o_convolved_data_valid <= convolved_data_valid_int;
end
endmodule
