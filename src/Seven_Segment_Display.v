`timescale 1ns / 1ps

module Seven_Segment_Display #(
    parameter CLOCK_FREQ = 50000000,    // 系统时钟频率，默认为 50 MHz
    parameter SCAN_FREQ  = 1000         // 扫描频率，默认为 1 kHz
)(
    input wire clk,                      // 系统时钟
    input wire rst,                      // 复位信号，高电平有效
    input wire [3:0] digit0,             // 第0位数字
    input wire [3:0] digit1,             // 第1位数字
    input wire [3:0] digit2,             // 第2位数字
    input wire [3:0] digit3,             // 第3位数字
    input wire [3:0] digit4,             // 第4位数字
    input wire [3:0] digit5,             // 第5位数字
    input wire [3:0] digit6,             // 第6位数字
    input wire [3:0] digit7,             // 第7位数字
    input wire dp0,                      // 第0位小数点控制，1 表示点亮
    input wire dp1,                      // 第1位小数点控制
    input wire dp2,                      // 第2位小数点控制
    input wire dp3,                      // 第3位小数点控制
    input wire dp4,                      // 第4位小数点控制
    input wire dp5,                      // 第5位小数点控制
    input wire dp6,                      // 第6位小数点控制
    input wire dp7,                      // 第7位小数点控制
    output reg dio,                      // 串行数据输出到第一个 SN74HC595 的 SER 引脚
    output reg rclk,                     // 存储寄存器时钟输出到 SN74HC595 的 RCLK 引脚
    output reg sclk                      // 移位寄存器时钟输出到 SN74HC595 的 SCLK 引脚
);

    // 计算扫描周期
    localparam SCAN_PERIOD = CLOCK_FREQ / SCAN_FREQ;

    // 计数器，用于生成扫描周期
    reg [31:0] scan_counter;  
    // 扫描状态（0-7），用于选择数码管
    reg [2:0] scan_state;     
    // 当前显示的段选信号（包含小数点）
    reg [7:0] segments;       
    // 位选信号，控制哪个数码管点亮
    reg [7:0] hex_sel;        

    // 数码管编码函数
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
                default: encode = 7'b0000001; // 显示 '-'
            endcase
        end
    endfunction

    // 扫描计数器和扫描状态更新
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_counter <= 0;
            scan_state <= 0;
        end else begin
            if (scan_counter < SCAN_PERIOD - 1)
                scan_counter <= scan_counter + 1;
            else begin
                scan_counter <= 0;
                if (scan_state == 3'd7)
                    scan_state <= 3'd0;
                else
                    scan_state <= scan_state + 1;
            end
        end
    end

    // 根据扫描状态设置段选和位选信号
    always @(*) begin
        case (scan_state)
            3'd0: begin
                // 显示第0位
                segments[6:0] = encode(digit0);
                segments[7]   = dp0;
                hex_sel        = 8'b11111110; // 低电平有效
            end
            3'd1: begin
                // 显示第1位
                segments[6:0] = encode(digit1);
                segments[7]   = dp1;
                hex_sel        = 8'b11111101;
            end
            3'd2: begin
                // 显示第2位
                segments[6:0] = encode(digit2);
                segments[7]   = dp2;
                hex_sel        = 8'b11111011;
            end
            3'd3: begin
                // 显示第3位
                segments[6:0] = encode(digit3);
                segments[7]   = dp3;
                hex_sel        = 8'b11110111;
            end
            3'd4: begin
                // 显示第4位
                segments[6:0] = encode(digit4);
                segments[7]   = dp4;
                hex_sel        = 8'b11101111;
            end
            3'd5: begin
                // 显示第5位
                segments[6:0] = encode(digit5);
                segments[7]   = dp5;
                hex_sel        = 8'b11011111;
            end
            3'd6: begin
                // 显示第6位
                segments[6:0] = encode(digit6);
                segments[7]   = dp6;
                hex_sel        = 8'b10111111;
            end
            3'd7: begin
                // 显示第7位
                segments[6:0] = encode(digit7);
                segments[7]   = dp7;
                hex_sel        = 8'b01111111;
            end
            default: begin
                segments = 8'b00000000;
                hex_sel  = 8'b11111111; // 所有数码管关闭
            end
        endcase
    end

    // 移位寄存器控制逻辑
    reg [15:0] shift_data;    // 16 位移位数据
    reg [4:0] shift_counter;  // 移位计数器（0-16）
    reg shifting;             // 是否正在移位

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dio           <= 0;
            rclk          <= 0;
            sclk          <= 0;
            shift_data    <= 16'b0;
            shift_counter <= 0;
            shifting      <= 0;
        end else begin
            // 在扫描计数器归零时，加载新的移位数据
            if (scan_counter == 0 && !shifting) begin
                // 构建移位数据
                // shift_data[15:8] -> HEX_SEL (8 位)
                // shift_data[7:0]  -> HEX_A 到 HEX_DP (8 位)
                shift_data    <= {hex_sel, segments}; // 总共16位
                shift_counter <= 16;
                shifting      <= 1;
                rclk          <= 0;
            end

            if (shifting) begin
                if (shift_counter > 0) begin
                    // 设置 DIO 为最高位
                    dio <= shift_data[15];
                    // 产生一个 SCLK 上升沿
                    sclk <= 1;
                end else if (shift_counter == 0 && shifting) begin
                    // 完成移位后，产生 RCLK 上升沿
                    rclk    <= 1;
                    shifting <= 0;
                end

                // 在下一个时钟周期降低 SCLK 并左移数据
                if (sclk) begin
                    sclk       <= 0;
                    shift_data <= shift_data << 1;
                    shift_counter <= shift_counter - 1;
                end else if (shift_counter == 0 && rclk) begin
                    rclk <= 0;
                end else if (shift_counter > 0 && !sclk) begin
                    sclk <= 1;
                end
            end
        end
    end

endmodule // Seven_Segment_Display
