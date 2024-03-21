`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/18 20:34:17
// Design Name: 
// Module Name: MemOrIO
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


module MemOrIO( mRead, mWrite, ioRead, ioWrite,ioRead2,ioWrite2,addr_in, addr_out, m_rdata,
 io_rdata,io_rdata2, r_wdata, r_rdata,write_data,negativeNumber);
input mRead; // read memory, from Controller
input mWrite; // write memory, from Controller
input ioRead; // read IO, from Controller
input ioWrite; // write IO, from Controller
input ioRead2;
input ioWrite2;
input[31:0] addr_in; // from alu_result in ALU
output[31:0] addr_out; // address to Data-Memory
input[31:0] m_rdata; // data read from Data-Memory
input[7:0] io_rdata; // data read from IO,8 bits
input[7:0] io_rdata2;
output reg[31:0] r_wdata; // data to Decoder(register file)
input[31:0] r_rdata; // data read from Decoder(register file)
output reg[31:0] write_data; // data to memory or I/O（m_wdata, io_wdata）
input negativeNumber;




assign addr_out=addr_in;
reg[7:0] temp_io_rdata;//对io_rdata取反后加一，得到负数
reg[7:0]temp_io_rdata2;
always@(io_rdata)begin
    temp_io_rdata[0]=!io_rdata[0];
     temp_io_rdata[1]=!io_rdata[1];
      temp_io_rdata[2]=!io_rdata[2];
       temp_io_rdata[3]=!io_rdata[3];
        temp_io_rdata[4]=!io_rdata[4];
         temp_io_rdata[5]=!io_rdata[5];
          temp_io_rdata[6]=!io_rdata[6];
           temp_io_rdata[7]=!io_rdata[7];
            temp_io_rdata=temp_io_rdata+1;
            
            
                temp_io_rdata2[0]=!io_rdata2[0];
             temp_io_rdata2[1]=!io_rdata2[1];
              temp_io_rdata2[2]=!io_rdata2[2];
               temp_io_rdata2[3]=!io_rdata2[3];
                temp_io_rdata2[4]=!io_rdata2[4];
                 temp_io_rdata2[5]=!io_rdata2[5];
                  temp_io_rdata2[6]=!io_rdata2[6];
                   temp_io_rdata2[7]=!io_rdata2[7];
                    temp_io_rdata2=temp_io_rdata2+1;
end


//执行LW指令，将io或者Mem中的数据准备写入寄存器中
always @(*) begin
        if(mRead == 1'b1) begin
            r_wdata <= m_rdata;
        end 
        else if(ioRead == 1'b1&&negativeNumber==0) begin
          r_wdata <= {{24{1'b0}}, io_rdata}; // 无符号拓展
        end 
        else if(ioRead ==1'b1 &&negativeNumber==1)begin
            r_wdata<={{24{1'b1}},temp_io_rdata};
        end
        else if(ioRead2==1'b1&&negativeNumber==0)begin
          r_wdata<= {{24{1'b0}}, io_rdata2}; 
        end
         else if(ioRead2==1'b1&&negativeNumber==1)begin
                 r_wdata<= {{24{1'b1}}, temp_io_rdata2}; 
               end
        
end

//执行SW指令，将寄存器中的数据准备写入io或Mem中
always@(*) begin
        if((mWrite==1) | | (ioWrite==1))begin
              if(mWrite==1'b1)begin
                     write_data<=r_rdata;
              end
              else if(ioWrite==1)begin
                    write_data<={24'b0,r_rdata[7:0]};  //io中仅仅只放低八位
              end
              else if(ioWrite2==1)begin
                    write_data<={24'b0,r_rdata[7:0]};  
              end
        end
        else begin
          write_data<=32'hZZZZZZZZ;
        end
end    
         
                

endmodule
