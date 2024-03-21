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
    output [31:0] read_data_1;               // ����ĵ�һ������
    output [31:0] read_data_2;               // ����ĵڶ�������
    input[31:0]  Instruction;               // ȡָ��Ԫ����ָ��
    input[31:0]  mem_data;   				//  ��DATA RAM or I/O portȡ��������
    input[31:0]  ALU_result;   				// ��ִ�е�Ԫ��������Ľ��
    input        Jal;                       //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
    input        RegWrite;                  // ���Կ��Ƶ�Ԫ
    input        MemtoReg;              // ���Կ��Ƶ�Ԫ
    input        RegDst;                    //��������Ŀ��Ĵ�����rd����rt
    output reg[31:0] Sign_extend;               // ��չ���32λ������
    input		 clock;                  //ʱ��
    input        reset;                // ��λ
    input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
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
    
    
// ��һ����ļĴ�����
     reg[31:0] registers[0:31];

     output[31:0] RegisterA0;
     output[31:0] RegisterA1;
     output[31:0] RegisterA2;
     assign RegisterA0=registers[4];
     assign RegisterA1=registers[5];
     assign RegisterA2=registers[6];
     
     wire[0:0] sign_immediate;
     input Jr;
     assign read_data_1= (Jr==1'b1)?registers[31]:registers[rs];//��Ҫ��ָ��ʵ��������ɶ���Ȱ�����һ����//��һ�����������������ܵ������Ȱ�����һ��ȡ
     assign read_data_2= registers[rt];
        
       
        
        assign sign_immediate=immediate[15];//��֪���ܻ��õ���immediate��������
        
        //�ڸÿ�����ɶ�immediate�ĸ���(��չ��32λ��
        
        //����ʵ��ָ����ʲô������չ//�����ƺ���bug
       always@(*)begin
            if (opcode==6'hd | | opcode==6'hc| | opcode==6'h9| |opcode==6'hb| | (opcode==0 && (function_opcode==6'h2b | | function_opcode == 6'h23)) )begin//ori����,addiu,andi,sltiu
                    Sign_extend={16'h0000,immediate};
            end
            else begin
                case(sign_immediate)
                    1'b1: Sign_extend={16'hFFFF,immediate};
                    1'b0: Sign_extend={16'h0000,immediate};
                endcase
            end
       end
            
        //������ȷ��Ҫд�ĸ��Ĵ���
        reg[4:0] register_toWrite;
        always@(*)begin
        //��Jal��RegDst���ж�
            casex({Jal, RegDst})
                2'b1x: register_toWrite=5'b11111;//�����ַ��ָ��Ĵ����ĵ�ַ
                2'b01: register_toWrite=rd;
                2'b00: register_toWrite=rt;
            endcase
        end    
        
        
        
        integer i;
        always@( posedge clock )begin//��������ʱ��д�����ݵ��Ĵ����� //�������ж�Ҫ�ĵ����ݵ��Ĵ�����
             if (reset==1'b1)begin
                   for(i=0;i<32;i=i+1)begin
                          registers[i]<=0 ;
                   end
             end
            else if(RegWrite==1'b1&&register_toWrite!=5'b00000)begin//������д��Ĵ�������,��ȡ��Ҫд��
                casex({Jal, MemtoReg, commit1, commit2})
                    4'b1xxx: registers[register_toWrite]<=opcplus4;
                    4'b0100: registers[register_toWrite]<=mem_data;
                    4'b0000: registers[register_toWrite]<=ALU_result;
                endcase
             end
         end

endmodule
