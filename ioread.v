`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ioread (
    input			reset,				// reset, active high ��λ�ź� (�ߵ�ƽ��Ч)
	input			ior1,		
	input           ior2,		// from Controller, 1 means read from input device(�ӿ���������I/O��)

    input	[7:0]ioread_data_switch,// the data from switch(���������Ķ����ݣ��˴����Բ��뿪��)
    output reg [7:0] ioread_data1 ,
    output reg [7:0] ioread_data2		// the data to memorio (���������������͸�memorio)
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
