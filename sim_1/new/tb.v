`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2024 20:11:17
// Design Name: 
// Module Name: tb
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

`define header 1080
`define imgsize 512*512


module tb(

output o_intr
    );

reg clk;
reg rst;
reg [7:0] imagedata;
integer file,file1,i;
reg imagedatavalid;
integer sentsize;
//wire o_intr;
wire [7:0] outdata;
wire outdatavalid;
integer receiveddata = 0;


initial
begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
end

initial 
begin
    rst = 0;
    imagedatavalid = 0;
    sentsize = 0;
    #100;
    rst = 0;
    #100;    
    file = $fopen("lenaGrey.bin","rb");
    file1 = $fopen("lenablurr.bmp","wb");
    for(i=0; i<`header;i=i+1)
    begin
        $fscanf(file,"%c",imagedata);
        $fwrite(file,"%c",imagedata);
    end
    for(i=0; i<4*512;i=i+1)
    begin
        @(posedge clk);
        $fscanf(file,"%c",imagedata);
        imagedatavalid <= 1'b1;
    end  
    sentsize = 4*512;
    @(posedge clk);
    imagedatavalid <= 1'b0;
    while(sentsize < `imgsize)
    begin
        @(posedge o_intr);
       for(i=0; i<512;i=i+1)
        begin
             @(posedge clk);
             $fscanf(file,"%c",imagedata);
             imagedatavalid <= 1'b1;
         end
        @(posedge clk);
        imagedatavalid <= 1'b0;  
    end 
    @(posedge clk);
    imagedatavalid <= 1'b0;
    @(posedge o_intr);
    for(i=0; i<512;i=i+1)
    begin
        @(posedge clk);
        imagedata <= 0;
        imagedatavalid <= 1'b1;
    end
      @(posedge clk);
      imagedatavalid <= 1'b0;
      @(posedge o_intr);
      for(i=0; i<512;i=i+1)
      begin
          @(posedge clk);
          imagedata <= 0;
          imagedatavalid <= 1'b1;
      end
      @(posedge clk);
      imagedatavalid <= 1'b0;
      $fclose(file); 
end
    
always @(posedge clk)
begin
    if(outdatavalid)
    begin
       $fwrite(file1,"%c",outdata); 
       receiveddata <= receiveddata +1;
       
    end
    if(receiveddata == `imgsize)
    begin
        $fclose(file1);
        $stop; 
    end
end
    
imageprocesstop tbs(
    
.axi_clk(clk),
.axi_rst(rst),
    
    
.i_data_valid(imagedatavalid),         //
.i_data(imagedata),               //Slave interface axi
 .o_data_ready(),        //
    
.o_data_valid(outdatavalid),        //
.o_data(outdata),              // master interface
.i_data_ready(1'b1),        //
    
.o_intr(o_intr)
        );
    
endmodule
