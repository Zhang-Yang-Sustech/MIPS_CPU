`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 17:08:25
// Design Name: 
// Module Name: Dmem32
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


module dmemory32(clock, memWrite, address, writeData, readData,
// UART Programmer Pinouts
upg_rst_i, // UPG reset (Active High)
upg_clk_i, // UPG ram_clk_i (10MHz)
upg_wen_i, // UPG write enable
upg_adr_i, // UPG write address
upg_dat_i, // UPG write data
upg_done_i // 1 if programming is finished
);
    input clock;   //Clock signal.
    input memWrite;  //From controller. 1'b1 indicates write operations to data-memory.
    input [31:0] address;  //The unit is byte. The address of memory unit which is to be read/writen.
    input [31:0] writeData; //Data to be wirten to the memory unit.
    output[31:0] readData;  //Data read from memory unit.

    wire clk;
    assign clk=!clock;
    
    // UART Programmer Pinouts
    input upg_rst_i; // UPG reset (Active High)
    input upg_clk_i; // UPG ram_clk_i (10MHz)
    input upg_wen_i; // UPG write enable
    input [13:0] upg_adr_i; // UPG write address
    input [31:0] upg_dat_i; // UPG write data
    input upg_done_i; // 1 if programming is finished
    
    // Part of dmemory32 module
    //Create a instance of RAM(IP core), binding the ports
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    RAM ram (
    .clka (kickOff ? clk : upg_clk_i),
    .wea (kickOff ? memWrite : upg_wen_i),
    .addra (kickOff ? address[15:2] : upg_adr_i),
    .dina (kickOff ? writeData : upg_dat_i),
    .douta (readData)
    );
  
endmodule
