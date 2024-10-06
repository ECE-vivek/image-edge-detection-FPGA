`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2024 08:34:13
// Design Name: 
// Module Name: imgcontrol
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


module imgcontrol(
input i_clk,
input i_rst,
input [7:0] i_pixel_data,          // Input line for module
input        i_pixel_data_valid,
output  reg [71:0] o_pixel_data,      // Output port for module
output       o_pixel_data_valid //
 );
 reg [8:0] pixelcounter;
 reg [1:0] currentwritrlinebuff;
 reg [1:0] currentrdlinebuff;
 reg [3:0] linebuffvalid;
 reg [3:0] linbuffrddata;
 wire [23:0]lb0data;
 wire [23:0]lb1data;
 wire [23:0]lb2data;
 wire [23:0]lb3data;
 reg [8:0] rdcounter;
 reg rd_linebuff;
 reg [11:0] totalpixcelcountr;
 reg  o_intr;
 reg rdstate;
 localparam IDLE = 'b0,
                RD_BUFF = 'b1;
assign o_pixel_data_valid = rd_linebuff;
always @(posedge i_clk)
 begin
    if(i_rst)
    totalpixcelcountr <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_linebuff)
        totalpixcelcountr <= totalpixcelcountr +1;
        else if(!i_pixel_data_valid & rd_linebuff)
         totalpixcelcountr <= totalpixcelcountr -1;
    end
 end
  always @(posedge i_clk)
  begin
    if(i_rst)
    begin
        rdstate <= IDLE;
        rd_linebuff <= 1'b0;
        o_intr <= 1'b0;
    end
    else 
    begin
        case(rdstate)
      IDLE: begin
       o_intr <= 1'b0;
            if(totalpixcelcountr >= 1536)
                begin
                    rd_linebuff <= 1'b1; 
                    rdstate <= RD_BUFF;                  
                end
            end
    RD_BUFF:begin
            if(rdcounter == 511)
                begin
                rdstate <= IDLE;
                 rd_linebuff <= 1'b0; 
                 o_intr <= 1'b1;
                end
            end
        endcase
    end
  end
 always @(posedge i_clk)
 begin
    if(i_rst)
     pixelcounter <= 00;
     else
     begin
    if(i_pixel_data_valid)
    pixelcounter <= pixelcounter + 1;
     end
 end
 always @(posedge i_clk)
 begin
    if(i_rst)
    currentwritrlinebuff <= 0;
    else
    begin
    if(pixelcounter == 511 & i_pixel_data_valid )
    currentwritrlinebuff <= currentwritrlinebuff + 1;
    end
 end
 always @(*)
 begin
 linebuffvalid = 4'h0;
 linebuffvalid[currentwritrlinebuff] = i_pixel_data_valid;
 end
always @(posedge i_clk)
 begin
    if(i_rst)
    rdcounter <= 0;
    else
    begin
        if(rd_linebuff)
        rdcounter <= rdcounter + 1;
    end
 end
 always @(posedge i_clk)
 begin
    if(i_rst)
    begin
        currentrdlinebuff <= 0;
    end
    else
    begin
        if(rdcounter == 511 & rd_linebuff)
        currentrdlinebuff <= currentrdlinebuff + 1;
    end
 end
 always @(*)
 begin
    case(currentrdlinebuff)
    0:begin
        o_pixel_data = {lb2data,lb1data,lb0data};
    end
    1:begin
        o_pixel_data = {lb3data,lb2data,lb1data};
    end
    2:begin
        o_pixel_data = {lb0data,lb3data,lb2data};
    end
    3:begin
        o_pixel_data = {lb1data,lb0data,lb3data};
    end
    endcase
 end
 always @(*)
 begin
    case(currentrdlinebuff)
    0:begin
        linbuffrddata[0]= rd_linebuff;
        linbuffrddata[1]= rd_linebuff;
        linbuffrddata[2]= rd_linebuff;
        linbuffrddata[3]= 1'b0;
    end
    1:begin
        linbuffrddata[0]= 1'b0;
        linbuffrddata[1]= rd_linebuff;
        linbuffrddata[2]= rd_linebuff;
        linbuffrddata[3]= rd_linebuff;
    end
    2:begin
        linbuffrddata[0]= rd_linebuff;
        linbuffrddata[1]= 1'b0;
        linbuffrddata[2]= rd_linebuff;
        linbuffrddata[3]= rd_linebuff;
    end
    2:begin
        linbuffrddata[0]= rd_linebuff;
        linbuffrddata[1]= rd_linebuff;
        linbuffrddata[2]= 1'b0;
        linbuffrddata[3]= rd_linebuff;
    end
    endcase
 end
 linbuff  lb0(
 .i_clk(i_clk),            //Clock
 .i_rst(i_rst),            // Reset 
 .i_data(i_pixel_data),             // One pixel value 8bit.
 .i_data_valid(linebuffvalid[0]),    // Data validation check
 .i_rd_data(linbuffrddata[0]),         // data read signal
 .o_data(lb0data)
 );
 linbuff  lb1( 
  .i_clk(i_clk),            //Clock
  .i_rst(i_rst),            // Reset 
  .i_data(i_pixel_data),             // One pixel value 8bit.
  .i_data_valid(linebuffvalid[1]),    // Data validation check
  .i_rd_data(linbuffrddata[1]),         // data read signal
  .o_data(lb1data)
  );
   linbuff  lb2( 
   .i_clk(i_clk),            //Clock
   .i_rst(i_rst),            // Reset 
   .i_data(i_pixel_data),             // One pixel value 8bit.
   .i_data_valid(linebuffvalid[2]),    // Data validation check
   .i_rd_data(linbuffrddata[2]),         // data read signal
   .o_data(lb2data)
   );
    linbuff  lb3( 
    .i_clk(i_clk),            //Clock
    .i_rst(i_rst),            // Reset 
    .i_data(i_pixel_data),             // One pixel value 8bit.
    .i_data_valid(linebuffvalid[3]),    // Data validation check
    .i_rd_data(linbuffrddata[3]),         // data read signal
    .o_data(lb3data)
    );
    endmodule
