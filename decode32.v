`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/14 11:02:15
// Design Name: 
// Module Name: decode32
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


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4,RegisterA0,RegisterA1,RegisterA2,commit1,commit2,Jr
               );
    output [31:0] read_data_1;               // 输出的第一操作数
    output [31:0] read_data_2;               // 输出的第二操作数
    input[31:0]  Instruction;               // 取指单元来的指令
    input[31:0]  mem_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				// 从执行单元来的运算的结果
    input        Jal;                       //  来自控制单元，说明是JAL指令 
    input        RegWrite;                  // 来自控制单元
    input        MemtoReg;              // 来自控制单元
    input        RegDst;                    //用于描述目标寄存器是rd还是rt
    output reg[31:0] Sign_extend;               // 扩展后的32位立即数
    input		 clock;                  //时钟
    input        reset;                // 复位
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    input commit1, commit2;

    
    wire  [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [15:0] immediate;
    wire [5:0]function_opcode;
    assign opcode =Instruction[31:26];
    assign function_opcode=Instruction[5:0];
    assign rs=Instruction[25:21];
    assign rt=Instruction[20:16];
    assign rd=Instruction[15:11];
    assign immediate=Instruction[15:0];
    
    
// 开一个大的寄存器堆
     reg[31:0] registers[0:31];

     output[31:0] RegisterA0;
     output[31:0] RegisterA1;
     output[31:0] RegisterA2;
     assign RegisterA0=registers[4];
     assign RegisterA1=registers[5];
     assign RegisterA2=registers[6];
     
     wire[0:0] sign_immediate;
     input Jr;
     assign read_data_1= (Jr==1'b1)?registers[31]:registers[rs];//不要管指令实际内容是啥，先把这俩一更新//这一部意义在于让正在跑的命令先把数据一读取
     assign read_data_2= registers[rt];
        
       
        
        assign sign_immediate=immediate[15];//获知可能会用到的immediate的正负性
        
        //在该块中完成对immediate的更新(扩展至32位）
        
        //不管实际指令是什么，先扩展//这里似乎有bug
       always@(*)begin
            if (opcode==6'hd | | opcode==6'hc| | opcode==6'h9| |opcode==6'hb| | (opcode==0 && (function_opcode==6'h2b | | function_opcode == 6'h23)) )begin//ori命令,addiu,andi,sltiu
                    Sign_extend={16'h0000,immediate};
            end
            else begin
                case(sign_immediate)
                    1'b1: Sign_extend={16'hFFFF,immediate};
                    1'b0: Sign_extend={16'h0000,immediate};
                endcase
            end
       end
            
        //首先是确定要写哪个寄存器
        reg[4:0] register_toWrite;
        always@(*)begin
        //对Jal与RegDst的判断
            casex({Jal, RegDst})
                2'b1x: register_toWrite=5'b11111;//这个地址是指令寄存器的地址
                2'b01: register_toWrite=rd;
                2'b00: register_toWrite=rt;
            endcase
        end    
        
        
        
        integer i;
        always@( posedge clock )begin//在上升沿时，写入数据到寄存器中 //接下来判断要哪的数据到寄存器中
             if (reset==1'b1)begin
                   for(i=0;i<32;i=i+1)begin
                          registers[i]<=0 ;
                   end
             end
            else if(RegWrite==1'b1&&register_toWrite!=5'b00000)begin//激活了写入寄存器功能,提取出要写的
                casex({Jal, MemtoReg, commit1, commit2})
                    4'b1xxx: registers[register_toWrite]<=opcplus4;
                    4'b0100: registers[register_toWrite]<=mem_data;
                    4'b0000: registers[register_toWrite]<=ALU_result;
                endcase
             end
         end

endmodule
