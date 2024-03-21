`timescale 1ns / 1ps
module executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4);
    input[31:0]  Read_data_1;		// 从译码单元的Read_data_1中来
    input[31:0]  Read_data_2;		// 从译码单元的Read_data_2中来
    input[31:0]  Sign_extend;		// 从译码单元来的扩展后的立即数
    input[5:0]   Function_opcode;  	// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// 取指单元来的操作码
    input[1:0]   ALUOp;             // 来自控制单元的运算指令控制编码
    input[4:0]   Shamt;             // 来自取指单元的instruction[10:6]，指定移位次数
    input  		 Sftmd;            // 来自控制单元的，表明是移位指令
    input        ALUSrc;            // 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
    input        I_format;          // 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
    input        Jr;               // 来自控制单元，表明是JR指令
    input[31:0]  PC_plus_4;         // 来自取指单元的PC+4
    output wire      Zero;              // 为1表明计算值为0 
    output reg [31:0] ALU_Result;        // 计算的数据结果
    output wire [31:0] Addr_Result;		// 计算的地址结果        
    
    wire signed [31:0] input1,input2;   
    assign input1 = Read_data_1;
    assign input2 = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];

    wire [32:0] Addr;
    assign Addr=PC_plus_4[31:0] + {Sign_extend[29:0],2'b0};
    assign Addr_Result=Addr[31:0];
    
    wire    [5:0] Exe_code;         
    assign Exe_code = (I_format==0) ? Function_opcode : { 3'b000 , Exe_opcode[2:0]};

    wire    [2:0] ALU_ctl;          
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    
    reg     [31:0] ALU_output_mux;
    always @(*) begin
        case(ALU_ctl)
            3'b000: ALU_output_mux = input1 & input2;
            3'b001: ALU_output_mux = input1 | input2;
            3'b010: ALU_output_mux = input1 + input2;
            3'b011: ALU_output_mux = input1 + input2;
            3'b100: ALU_output_mux = input1 ^ input2;
            3'b101: ALU_output_mux = ~(input1 | input2);
            3'b110: ALU_output_mux = input1 - input2;
            3'b111: ALU_output_mux = input1 - input2;
            default: ALU_output_mux <= 32'h0000_0000;
        endcase        
    end
    assign Zero = (ALU_output_mux[31:0] == 32'h00000000) ? 1'b1 : 1'b0;
    
    reg     [31:0] Shift_Result;    
    wire    [2:0] Sftm;             
    assign Sftm = Function_opcode[2:0]; 
    always @(*) begin
        if(Sftmd) begin
          case (Sftm[2:0])
            3'b000: Shift_Result <= input2 << Shamt; // sll
            3'b010: Shift_Result <= input2 >> Shamt; // srl
            3'b100: Shift_Result <= input2 << input1; // sllv
            3'b110: Shift_Result <= input2 >> input1; // srlv
            3'b011: Shift_Result <= input2 >>> Shamt; // sra
            3'b111: Shift_Result <= input2 >>> input1; // srav
            default:Shift_Result <= input2;
          endcase
        end
        else begin
          Shift_Result <= input2;
        end
    end

    always @(*) begin
        if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||((ALU_ctl[2:1]==2'b11) && (I_format==1))) begin
            ALU_Result <= (input1-input2<0)?1:0;
        end
       
        else if((ALU_ctl==3'b101) && (I_format==1)) begin
            ALU_Result[31:0] <= {input2[15:0],{16{1'b0}}};
        end
       
        else if(Sftmd == 1'b1) begin
            ALU_Result <= Shift_Result;
        end
        
        else begin
            ALU_Result <= ALU_output_mux[31:0];
        end
        
    end
endmodule
