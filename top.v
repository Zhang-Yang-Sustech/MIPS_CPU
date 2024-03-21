`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 16:16:11
// Design Name: 
// Module Name: top
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


 module top(clock0, fpga_rst, switch ,cases, choose, comit1,comit2,seg_en,seg,seg1,testLight1,testLight2,
 start_pg,rx,tx,negativeNumber,deterResult, hsync, vsync, vga_rgb );
    input clock0;
    input fpga_rst;
    input [7:0] switch;//开关上的数据
    input [2:0] cases;
    input choose;
    input comit1;//提交io中的数据到寄存器中，并让IF模块恢复
    input comit2;
    output [7:0] seg_en;
    output [7:0] seg;
    output [7:0] seg1;
    output testLight1;
    output testLight2;
    output deterResult;
    output hsync, vsync;
    output[11:0] vga_rgb;

    wire clock;
   
    input start_pg;
    input rx;
    input negativeNumber;//表示接下来从IO中读取的数字为负数
    output tx;
    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o; //Uart write out enable
    wire upg_done_o; //Uart rx data have done
    //data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    //data to program_rom or dmemory32
    wire [31:0] upg_dat_o;
    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter
    // Generate UART Programmer reset signal
    reg upg_rst;
    always @ (posedge clock) begin
    if (spg_bufg) upg_rst = 0;
    if (fpga_rst) upg_rst = 1;
    end
    //used for other modules which don't relate to UART
    wire rst;
    assign rst = fpga_rst | !upg_rst;
     //clk
       cpuclk clk(
           .clk_in1(clock0),
           .clk_out1(clock),
           .clk_out2(upg_clk)
       );
    
    uart_bmpg_0 u1(
    .upg_clk_i(upg_clk),
    .upg_rst_i(upg_rst),
    .upg_rx_i(rx),
    .upg_clk_o(upg_clk_o),
    .upg_wen_o(upg_wen_o),
    .upg_adr_o(upg_adr_o),
    .upg_dat_o(upg_dat_o),
    .upg_done_o(upg_done_o),
    .upg_tx_o(tx)
    );
    
    
    // Ifetch32 模块 第一步-取指
        /////////////////////////////////////////////////////////////
        wire [31:0] Addr_result;        // 从ALU计算出的地址
        wire Zero;                      // 1-ALU Reuslt = 0
        wire [31:0] Read_data_1;        // 读数据1 / jr指令所使用的指令地址
        wire Branch, nBranch, Jmp, Jal, Jr/*, Sys*/; // 控制信号 beq,bne,j,jal,jr
        wire [31:0] Instruction;        // 指令
        wire [31:0] branch_base_addr;   // PC + 4 分支指令使用，多跳一位
        wire [31:0] link_addr;          // jal 指令使用的 $32 寄存器保存的跳转回来的指令
          wire RegDST, MemOrIOtoReg, RegWrite, MemWrite,MemRead,
          io_Read1,io_Write1,io_Read2,io_Write2;
              wire ALUSrc, I_format, Sftmd;
              wire [1:0] ALUOp;
               wire [31:0] ALU_result; // ALU 计算结果
               wire [31:0] Read_data_2; // 读数据2
               wire [31:0] imme_extend; // 立即数(符号拓展)
               
              wire [31:0] m_Wdata;//要写入IO或者内存中的数据，应当与Demeory和control模块有关
                   wire [31:0] m_Rdata;
                wire [31:0] addr_Out;//内存地址值,受MEmOrIO模块管理
                    
                    wire [7:0] io_Rdata;
                    wire [7:0] io_Rdata2;
                    wire [31:0] r_Wdata;
                     wire [31:0]r_Rdata;
                     assign r_Rdata = Read_data_2;
                     wire exit; //当opcode与function_opcode时，程序结束，由control模块将之调整为1，告知ifetch停止读取指令
                     wire [31:0]pc;
                    
              
        Ifetc32 IFetch(
                .clock(clock),
                .reset(rst),
                .Addr_result(Addr_result),
                .Zero(Zero),
                .Read_data_1(Read_data_1),
                .Branch(Branch),
                .nBranch(nBranch),
                .Jmp(Jmp),
                .Jal(Jal),
                .Jr(Jr),
                .Instruction(Instruction),
                .branch_base_addr(branch_base_addr),
                .link_addr(link_addr),
                .choose(choose),
                .cases(cases),
                .exit(exit),
                .ioRead1(io_Read1),
                .ioRead2(io_Read2),
                .pc(pc),
                .commit1(comit1),
                .commit2(comit2),
                .upg_rst_i(upg_rst),
                .upg_clk_i(upg_clk_o),
                .upg_wen_i(upg_wen_o&(!upg_adr_o[14])),
                .upg_adr_i(upg_adr_o[13:0]),
                .upg_dat_i(upg_dat_o),
                .upg_done_i(upg_done_o)
             
        );
        

      


     

 

 
    
    

    // control32 模块 第二部-控制信号
            /////////////////////////////////////////////////////////////
            control32 Controller(
                .Opcode(Instruction[31:26]),
                .Function_opcode(Instruction[5:0]),
                .Jr(Jr),
                 .Branch(Branch),
                .nBranch(nBranch),
                .Jmp(Jmp),
                .Jal(Jal),
                .RegDST(RegDST),
                .MemorIOtoReg(MemOrIOtoReg),
                .RegWrite(RegWrite),
                .MemRead(MemRead),
                .MemWrite(MemWrite),
                .ALUSrc(ALUSrc),
                 .ALUOp(ALUOp),
                 .Sftmd(Sftmd),
                .I_format(I_format),
                .Alu_resultHigh(ALU_result[31:0]),
                .IORead1(io_Read1),
                .IOWrite1(io_Write1),
                .IORead2(io_Read2),
                .IOWrite2(io_Write2),
                .exitProgramme(exit),
                .instruction(Instruction)
        );       

     // Executs32 模块 第四步-进行指令的运算
    /////////////////////////////////////////////////////////////

     executs32 ALU(
         .Read_data_1(Read_data_1),
         .Read_data_2(Read_data_2),
         .Sign_extend(imme_extend),
         .Exe_opcode(Instruction[31:26]),
         .Function_opcode(Instruction[5:0]),
         .Shamt(Instruction[10:6]),
         .PC_plus_4(branch_base_addr),
         .ALUOp(ALUOp),
         .ALUSrc(ALUSrc),
         .I_format(I_format),
         .Sftmd(Sftmd),
         .Jr(Jr),
         .Zero(Zero),
         .ALU_Result(ALU_result),
         .Addr_Result(Addr_result)
         );
  // dmemory32 模块 第五步-指令写入/读出内存
 /////////////////////////////////////////////////////////////
 // write_data 是用 Read_data_2 的吗？
 // address 是用 ALU_result 的吗？
 
assign testLight1=((io_Rdata>0)?1'b1:1'b0) ;
assign testLight2=((io_Rdata2>0)?1'b1:1'b0 );
  
        //mRead, mWrite, ioRead, ioWrite,addr_in, addr_out, m_rdata, io_rdata, r_wdata, r_rdata,write_data
                MemOrIO memOrIo(
                    .mRead(MemRead ),
                    .mWrite(MemWrite ),
                    .ioRead(io_Read1 ),
                    .ioWrite( io_Write1),
                    .ioRead2(io_Read2),
                    .ioWrite2(io_Write2),
                    .addr_in(ALU_result ),
                    .addr_out(addr_Out ),
                    .m_rdata(m_Rdata),
                   .io_rdata(io_Rdata ),
                   .io_rdata2(io_Rdata2),
                  
                    .r_wdata(r_Wdata ),
                    .r_rdata(r_Rdata ),
                    .write_data( m_Wdata),
                    
                    .negativeNumber(negativeNumber)

                );
  
   // dmemory32 模块 第五步-指令写入/读出内存
  /////////////////////////////////////////////////////////////
  // write_data 是用 Read_data_2 的吗？
  // address 是用 ALU_result 的吗？
            dmemory32 Memory(
                  .clock(clock),
                  .address( addr_Out),
                   .memWrite(MemWrite),
                 .writeData(m_Wdata),
                  .readData(m_Rdata),
                  .upg_rst_i(upg_rst),
                  .upg_clk_i(upg_clk_o),
                  .upg_wen_i(upg_wen_o&upg_adr_o[14]),
                  .upg_adr_i(upg_adr_o[13:0]),
                  .upg_dat_i(upg_dat_o),
                  .upg_done_i(upg_done_o)
                 );
 
 



                
                ioread ioReadModule(
                    .reset(rst),
                    .ior1(io_Read1),
                    .ior2(io_Read2),
                    . ioread_data_switch(switch ),
                    .ioread_data1(io_Rdata ),
                    .ioread_data2(io_Rdata2)
                    
                );
    
                wire [31:0] A0;//decode中的三个寄存器，a0、a2分别用于显示测试数字结果，a1用于表示是否溢出
                wire [31:0] A1;
                wire [31:0] A2;

 
        // Idecode32 模块 第三步-解码
        /////////////////////////////////////////////////////////////
    decode32 Decoder(
            .clock(clock),
            .reset(rst),
            .Instruction(Instruction),
            .mem_data(r_Wdata),
            .ALU_result(ALU_result),
            .Jal(Jal),
            .RegWrite(RegWrite),
            .MemtoReg(MemOrIOtoReg),
            .RegDst(RegDST),
            .opcplus4(link_addr),
            .read_data_1(Read_data_1),
            .read_data_2(Read_data_2),
            .Sign_extend(imme_extend),
            .RegisterA0(A0),
            .RegisterA1(A1),
            .RegisterA2(A2),
            .Jr(Jr)

    );
    


        
        assign seg1 = seg;
        leds LED(
               .clk(clock),
               .rst(rst),
               .a0(A0),
               .a1(A1),
               .a2(A2),
               .seg_en(seg_en),
               .seg(seg),
               .deterResult(deterResult)
        );

        vga vga_module(
            .sys_clk(clock0),//10oMhz时钟
            .sys_rst(rst),//reset
        
            .a0(A0),
            .a1(A1),
            .a2(A2),
        
            .hsync(hsync),
            .vsync(vsync),
            .vga_rgb(vga_rgb)
        );

    
endmodule
