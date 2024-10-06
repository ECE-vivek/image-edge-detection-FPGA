`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2024 20:32:23
// Design Name: 
// Module Name: imageprocesstop
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


module imageprocesstop(

input axi_clk,
input axi_rst,


input i_data_valid,         //
input [7:0] i_data,         //Slave interface axi
output o_data_ready,        //

output o_data_valid,        //
output [7:0] o_data,        // master interface
input i_data_ready,         //

output intr
    );
    
    
 wire [71:0] pixel_data;
 wire pixel_data_valid;
 wire [7:0] convolved_data;
 wire convolveddata_valid;
 wire axis_prog_full;
  
assign o_data_ready = !axis_prog_full;
  
  imgcontrol imgcontrol(
    .i_clk(axi_clk),
    .i_rst(axi_rst),
    .i_pixel_data(i_data),                   // Input line for module
    .i_pixel_data_valid(i_data_valid),
    .o_pixel_data(pixel_data),               // Output port for module
    .o_pixel_data_valid(pixel_data_valid),    //
    .o_intr(intr)
    
    );
       
    conv conv(
   .i_clk(axi_clk),                          //
   .i_pixel_data(pixel_data),                // Input linr for module
   .i_pixel_data_valid(pixel_data_valid),    //  
   .o_convolved_data(convolved_data),                // Output port for module
   .o_convolved_data_valid(convolveddata_valid)     //
        );
         outputbuff ob(
          .wr_rst_busy(),        // output wire wr_rst_busy
          .rd_rst_busy(),        // output wire rd_rst_busy
          .s_aclk(axi_clk),                  // input wire s_aclk
          .s_aresetn(axi_rst),            // input wire s_aresetn
          .s_axis_tvalid(convolveddata_valid),    // input wire s_axis_tvalid
          .s_axis_tready(),    // output wire s_axis_tready
          .s_axis_tdata(convolved_data),      // input wire [7 : 0] s_axis_tdata
          .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
          .m_axis_tready(i_data_ready),    // input wire m_axis_tready
          .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
          .axis_prog_full(axis_prog_full)  // output wire axis_prog_full  
        );
    
    
endmodule
