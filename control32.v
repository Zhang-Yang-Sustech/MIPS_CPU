`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 17:10:49
// Design Name: 
// Module Name: Controller
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


module control32(
Opcode,Function_opcode, Jr,Branch,nBranch,Jmp,Jal, RegDST,MemorIOtoReg,RegWrite,MemRead,
MemWrite,IORead1,IOWrite1,IORead2,IOWrite2, ALUSrc,ALUOp,Sftmd,I_format,Alu_resultHigh,exitProgramme,instruction
    );
    input [5:0] Opcode, Function_opcode; //reg type variables are use for binding with input ports
    output [1:0] ALUOp; //wire type variables are use for binding with output ports
    input [31:0] Alu_resultHigh;//来自于计算单元中Alu_Result[31:0];
    output Jr, RegDST, ALUSrc, MemorIOtoReg, RegWrite,MemRead, MemWrite,
     Branch, nBranch, Jmp, Jal, I_format, Sftmd, IOWrite1 , IOWrite2;
    
    output  IORead1;
    output  IORead2;
    output exitProgramme;
    input [31:0] instruction;
    assign exitProgramme=(instruction==32'b0)?1'b1:1'b0;
    
    
    
    
    wire R_format;
    wire Lw; 
    assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;

    wire Sw;
    assign Sw = (Opcode==6'b101011) ? 1'b1:1'b0;
    

    assign Jr =((Opcode==6'b000000)&&(Function_opcode==6'b001000)) ? 1'b1 : 1'b0;
    assign Jmp =(Opcode==6'b000010) ? 1'b1 : 1'b0;
    assign Jal =(Opcode==6'b000011) ? 1'b1 : 1'b0;
    assign Branch =(Opcode==6'b000100) ? 1'b1 : 1'b0;
    assign nBranch =(Opcode==6'b000101)? 1'b1 : 1'b0;
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;
    assign RegDST = R_format;
    assign I_format = (Opcode[5:3]==3'b001) ? 1'b1 : 1'b0;
    assign ALUOp = { (R_format || I_format) , (Branch || nBranch)};
    assign Sftmd = (((Function_opcode==6'b000000)||(Function_opcode==6'b000010)||(Function_opcode==6'b000011)||(Function_opcode==6'b000100)||(Function_opcode==6'b000110)||(Function_opcode==6'b000111))&& R_format) ? 1'b1 : 1'b0;
    assign ALUSrc = I_format || Lw || Sw;
    assign RegWrite = (R_format || Lw || Jal || I_format) && !(Jr); //要向寄存器中写数据
    
    
    assign MemorIOtoReg=IORead1| |MemRead | | IORead2;
    assign MemWrite=( (Sw==1) & & (Alu_resultHigh[31:0] !=32'h0000_3FFF) && (Alu_resultHigh[31:0] !=32'h0000_3FFB) ) ?1'b1:1'b0;
    assign MemRead=( (Lw==1) & & (Alu_resultHigh[31:0] !=32'h0000_3FFF)&& (Alu_resultHigh[31:0] !=32'h0000_3FFB)  ) ?1'b1:1'b0;

    
  assign IORead1=( (Lw==1) && (Alu_resultHigh[31:0]==32'h0000_3FFF))?1'b1:1'b0;
    
   assign IOWrite1=( (Sw==1) & & (Alu_resultHigh[31:0] ==32'h0000_3FFF) ) ?1'b1:1'b0;
    
   assign IORead2=( (Lw==1) && (Alu_resultHigh[31:0]==32'h0000_3FFB)  )?1'b1:1'b0;

   assign IOWrite2=( (Sw==1) & & (Alu_resultHigh[31:0] ==32'h0000_3FFB) ) ?1'b1:1'b0;
endmodule
