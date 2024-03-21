`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds (
    input clk,
    input rst,
    input[2:0] cases,//用于找出几个需要用小灯亮起做判断结果的样例
    input[0:0]choose,
    input [31:0] a0,
    input [31:0] a1,
    input [31:0] a2,
    output reg [7:0] seg_en,
    output reg [7:0] seg ,

    output deterResult
);
    parameter ms = 15'd23000;
    parameter ms_8 = 18'd184000;
    parameter s = 25'd23000_000;
    parameter five_s = 28'd115000_000;
    parameter zero = 28'd0;
    reg [3:0] out;
    reg [1:0] turn;
    reg [31:0] a;
    reg [27:0] cnt;
    reg [17:0] cnt_ms;
    assign deterResult=(({choose,cases}==4'b0000 || {choose,cases}==4'b0001 ||{choose,cases}==4'b0101 ||{choose,cases}==4'b0110
                                        || {choose,cases}==4'b1100 || {choose,cases}==4'b1101 )&&a1>0)?1'b1:1'b0;
    always @ * begin
        case (turn)
            2'b00: a <= a0;
            2'b01: a <= a1;
            2'b10: a <= a2;
        endcase
        case (cnt_ms/ms) 
            3'b000: out <= a[31:28];
            3'b001: out <= a[27:24];
            3'b010: out <= a[23:20];
            3'b011: out <= a[19:16];
            3'b100: out <= a[15:12];
            3'b101: out <= a[11:8];
            3'b110: out <= a[7:4];
            3'b111: out <= a[3:0];
        endcase

    end
    reg flash_cost=5'b00_000;//用于实现闪烁
    always @ (negedge clk) begin
        case (cnt_ms/ms) 
            3'b000: seg_en <= 8'b1000_0000;
            3'b001: seg_en <= 8'b0100_0000;
            3'b010: seg_en <= 8'b0010_0000;
            3'b011: seg_en <= 8'b0001_0000;
            3'b100: seg_en <= 8'b0000_1000;
            3'b101: seg_en <= 8'b0000_0100;
            3'b110: seg_en <= 8'b0000_0010;
            3'b111: seg_en <= 8'b0000_0001;
        endcase
        case (out)
             4'h0:seg =8'b1111_1100;
             4'h1:seg =8'b0110_0000;
             4'h2:seg =8'b1101_1010;
             4'h3:seg =8'b1111_0010;
             4'h4:seg =8'b0110_0110;
             4'h5:seg =8'b1011_0110;
             4'h6:seg =8'b1011_1110;
             4'h7:seg =8'b1110_0000;
             4'h8:seg =8'b1111_1110;
             4'h9:seg =8'b1110_0110;
             4'ha:seg =8'b1110_1110;
             4'hb:seg =8'b0011_1110;
             4'hc:seg =8'b1001_1100;
             4'hd:seg =8'b0111_1010;
             4'he:seg =8'b1001_1110;
             4'hf:seg =8'b1000_1110;
             default: seg = 8'b0000_0001;
        endcase
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) begin
            cnt<=zero;
            turn<=2'b00;
            cnt_ms<=18'd0;
        end
        else begin
            if(cnt == five_s) begin
                cnt <= zero;
                if (turn == 2'b10) turn <= 2'b00;
                else turn <= turn + 1'b1;
            end
            else cnt  <= cnt +1'b1;
            if (cnt_ms == ms_8) cnt_ms <= 18'd0;
            else cnt_ms <= cnt_ms + 1'b1;
        end

     end
    
    
    
    
    
   
	
endmodule
