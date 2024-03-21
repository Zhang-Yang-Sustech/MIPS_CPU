`timescale 1ns / 1ps
module executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4);
    input[31:0]  Read_data_1;		// �����뵥Ԫ��Read_data_1����
    input[31:0]  Read_data_2;		// �����뵥Ԫ��Read_data_2����
    input[31:0]  Sign_extend;		// �����뵥Ԫ������չ���������
    input[5:0]   Function_opcode;  	// ȡָ��Ԫ����r-����ָ�����,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// ȡָ��Ԫ���Ĳ�����
    input[1:0]   ALUOp;             // ���Կ��Ƶ�Ԫ������ָ����Ʊ���
    input[4:0]   Shamt;             // ����ȡָ��Ԫ��instruction[10:6]��ָ����λ����
    input  		 Sftmd;            // ���Կ��Ƶ�Ԫ�ģ���������λָ��
    input        ALUSrc;            // ���Կ��Ƶ�Ԫ�������ڶ�������������������beq��bne���⣩
    input        I_format;          // ���Կ��Ƶ�Ԫ�������ǳ�beq, bne, LW, SW֮���I-����ָ��
    input        Jr;               // ���Կ��Ƶ�Ԫ��������JRָ��
    input[31:0]  PC_plus_4;         // ����ȡָ��Ԫ��PC+4
    output wire      Zero;              // Ϊ1��������ֵΪ0 
    output reg [31:0] ALU_Result;        // ��������ݽ��
    output wire [31:0] Addr_Result;		// ����ĵ�ַ���        
    
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
