`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 18:46:27
// Design Name: 
// Module Name: Ifetc32
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


module Ifetc32(Instruction,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr, choose, cases,exit,
ioRead1,ioRead2, pc, commit1, commit2,
// UART Programmer Pinouts
upg_rst_i, // UPG reset (Active High)
upg_clk_i, // UPG clock (10MHz)
upg_wen_i, // UPG write enable
upg_adr_i, // UPG write address
upg_dat_i, // UPG write data
upg_done_i // 1 if program finished
);
    input [31:0]  Addr_result;           // ALU�м�����ĵ�ַ
    input [31:0]  Read_data_1;           // jrָ�����PCʱ�õĵ�ַ
    input        Branch;                // ��BranchΪ1ʱ����ʾ��ǰָ����beq
    input        nBranch;               // ��nBranchΪ1ʱ����ʾ��ǰָ��Ϊbnq
    input        Jmp;                   // ��JmpΪ1ʱ����ʾ��ǰָ��Ϊjump
    input        Jal;                   // ��JalΪ1ʱ����ʾ��ǰָ��Ϊjal
    input        Jr;                    // ��JrΪ1ʱ����ʾ��ǰָ��Ϊjr
    input        Zero;                  // ��ZeroΪ1ʱ����ʾALUresultΪ0
    input        clock,reset;           // ʱ���븴λ��ͬ����λ�źţ��ߵ�ƽ��Ч����reset=1ʱ��PC��ֵΪ0��
    input        choose;
    input [2:0]cases;
    input ioRead1,ioRead2;
    input commit1, commit2;
    output [31:0]pc;
    input exit;//���յ���ָ��ʱ��˵���Ѿ����е��˳���ĩβ����ָֹ���ȡ
    /*input        sys;
    input        com;*/
    output [31:0] Instruction;			// �����ģ���ȡ����ָ����������ģ��
    output [31:0] branch_base_addr;      // ����beq,bneָ�(pc+4)�����ALU
    output reg [31:0] link_addr;             // ����jalָ�(pc+4)�����������
    // UART Programmer Pinouts
    input upg_rst_i; // UPG reset (Active High)
    input upg_clk_i; // UPG clock (10MHz)
    input upg_wen_i; // UPG write enable
    input[13:0] upg_adr_i; // UPG write address
    input[31:0] upg_dat_i; // UPG write data
    input upg_done_i; // 1 if program finished
    
    
        
    reg[31:0] PC, Next_PC;
        assign pc = PC;

    assign branch_base_addr = PC + 4;
        
    always @* begin
        if (exit==1 | | ioRead1==1 | | ioRead2==1)
            Next_PC = PC;
        else if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero == 0))) // beq, bne
            Next_PC =  Addr_result;// the calculated new value for PC
        else if(Jr == 1)
            Next_PC = Read_data_1 ; // the value of $31 register
        else 
        Next_PC = branch_base_addr; // PC+4
    end
    
    always @(negedge clock) begin
        if(reset == 1)
            case ({choose, cases}) 
            4'b0000: PC <= 32'h0000_0000;
            4'b0001: PC <= 32'h0000_0004;
            4'b0010: PC <= 32'h0000_0008;
            4'b0011: PC <= 32'h0000_000c;
            4'b0100: PC <= 32'h0000_0010;
            4'b0101: PC <= 32'h0000_0014;
            4'b0110: PC <= 32'h0000_0018;
            4'b0111: PC <= 32'h0000_001c;
            4'b1000: PC <= 32'h0000_0020;
            4'b1001: PC <= 32'h0000_0024;
            4'b1010: PC <= 32'h0000_0028;
            4'b1011: PC <= 32'h0000_002c;
            4'b1100: PC <= 32'h0000_0030;
            4'b1101: PC <= 32'h0000_0034;
            4'b1110: PC <= 32'h0000_0038;
            4'b1111: PC <= 32'h0000_003c;            
            endcase
        else if((Jmp == 1) || (Jal == 1)) begin
                        PC <= {branch_base_addr[31:28], Instruction[25:0], 2'b00};
                        link_addr <= branch_base_addr;
        end
        else if((commit1 == 1 && ioRead1 ==1)||(commit2 == 1 && ioRead2 ==1))
            PC <= branch_base_addr;
        else PC <= Next_PC;
    end
   wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i );
   
   
    prgrom instmem (
    .clka (kickOff ? clock : upg_clk_i ),
    .wea (kickOff ? 1'b0 : upg_wen_i ),
    .addra (kickOff ? PC[15:2] : upg_adr_i ),
    .dina (kickOff ? 32'h00000000 : upg_dat_i ),
    .douta (Instruction)    );
    
endmodule


