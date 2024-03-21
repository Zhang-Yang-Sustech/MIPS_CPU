`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ioread (
    input			reset,				// reset, active high 复位信号 (高电平有效)
	input			ior1,		
	input           ior2,		// from Controller, 1 means read from input device(从控制器来的I/O读)

    input	[7:0]ioread_data_switch,// the data from switch(从外设来的读数据，此处来自拨码开关)
    output reg [7:0] ioread_data1 ,
    output reg [7:0] ioread_data2		// the data to memorio (将外设来的数据送给memorio)
);
    

    
    always @* begin
        if (reset)begin
            ioread_data1 = 8'b0000_0000;
            ioread_data2 = 8'b0000_0000;
            end
        else begin
        if (ior1)
            ioread_data1 = ioread_data_switch;    
        else 
            ioread_data1 = ioread_data1;
        if (ior2) 
            ioread_data2 = ioread_data_switch;    
        else 
            ioread_data2 = ioread_data2;
        end
    end
	
endmodule
