`timescale 1ns / 1ps
module Seven_Segment_Display (
    input wire clk,
    input wire rst,
    input wire [3:0] hundreds,
    input wire [3:0] tens,
    input wire [3:0] units,
    input wire dp_hundreds, // 小数点控制，1 表示点亮
    input wire dp_tens,
    input wire dp_units,
    output reg [6:0] seg,    // a, b, c, d, e, f, g
    output reg [2:0] an      // 位选信号，低有效
    );

    // 数码管扫描周期
    parameter SCAN_FREQ = 100_000; // 100 kHz
    parameter SCAN_PERIOD = 10_000_000 / SCAN_FREQ; // 计数周期

    reg [19:0] scan_counter; // 20-bit 计数器
    reg [1:0] scan_state;    // 当前扫描的数码管

    // 数码管编码表
    function [6:0] encode;
        input [3:0] num;
        begin
            case (num)
                4'd0: encode = 7'b1111110;
                4'd1: encode = 7'b0110000;
                4'd2: encode = 7'b1101101;
                4'd3: encode = 7'b1111001;
                4'd4: encode = 7'b0110011;
                4'd5: encode = 7'b1011011;
                4'd6: encode = 7'b1011111;
                4'd7: encode = 7'b1110000;
                4'd8: encode = 7'b1111111;
                4'd9: encode = 7'b1111011;
                default: encode = 7'b0000001; // 默认显示 '-'
            endcase
        end
    endfunction

    // 数码管扫描逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_counter <= 0;
            scan_state <= 0;
            seg <= 7'b0000001;
            an <= 3'b111; // 数码管未选中
        end
        else begin
            if (scan_counter < SCAN_PERIOD -1)
                scan_counter <= scan_counter + 1;
            else begin
                scan_counter <= 0;
                scan_state <= scan_state + 1;
            end

            case (scan_state)
                2'd0: begin
                    // 显示个位
                    seg <= encode(units);
                    an <= 3'b110; // 选中个位
                    if (dp_units)
                        seg[6] <= 1; // 假设 g 段作为小数点控制
                end
                2'd1: begin
                    // 显示十位
                    seg <= encode(tens);
                    an <= 3'b101; // 选中十位
                    if (dp_tens)
                        seg[6] <= 1;
                end
                2'd2: begin
                    // 显示百位
                    seg <= encode(hundreds);
                    an <= 3'b011; // 选中百位
                    if (dp_hundreds)
                        seg[6] <= 1;
                end
                default: begin
                    seg <= 7'b0000001;
                    an <= 3'b111;
                end
            endcase
        end
    end

endmodule
