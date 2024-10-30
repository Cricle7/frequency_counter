module Measurement_Processor #(
    parameter CLOCK_FREQ = 50000000
)(
    input wire clk, // 系统时钟
    input wire rst_n, // 复位信号，高电平有效
    input wire measurement_done, // 测量完成信号
    input wire [31:0] period_time, // 信号周期 (秒)
    output reg [15:0]Segment_freq,
    output reg [15:0]Segment_period,
    output reg [2:0]point_1,//频率小数点
    output reg [2:0]point_2,//周期小数点
    output reg k,//频率单位
    output reg m//周期
);
    // 内部信号定义
    wire                   divider_done;             // 频率除法完成信号
    wire [31:0]            frequency_quotient;      // 频率除法商

    wire                   bcd_freq_done;            // 频率BCD转换完成信号
    wire [23:0]            freq_bcd;                // 频率的BCD表示
    wire [19:0]            freq_bcd_rounded;        // 频率BCD四舍五入后
    wire [31:0]            period_out;              // 周期除法商

    wire                   bcd_period_done;          // 周期BCD转换完成信号
    wire [23:0]            period_bcd;              // 周期的BCD表示
    wire [19:0]            period_bcd_rounded;      // 周期BCD四舍五入后
    wire                   bcd_freq_round_done;     // 频率BCD四舍五入完成信号
    wire                   bcd_period_round_done;   // 周期BCD四舍五入完成信号

    // 频率计算模块实例化
    Iterative_Divider divide_freq (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (measurement_done),
        .numerator  (32'd5000),                // 分子
        .divisor    (period_time),             // 分母
        .quotient   (frequency_quotient),      // 商
        .done       (divider_done)             // 完成信号
    );

    // 频率二进制转BCD模块实例化
    Binary_to_BCD bcd_freq_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (divider_done),
        .binary_in  (frequency_quotient),
        .bcd        (freq_bcd),
        .done       (bcd_freq_done)
    );

    // 频率BCD四舍五入模块实例化
    BCD_Rounding bcd_freq_round_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (bcd_freq_done),
        .BCD_in     (freq_bcd),
        .BCD_out    (freq_bcd_rounded),
        .done       (bcd_freq_round_done)
    );

    // 周期计算模块实例化
    Pipelined_Optimized_Divider_5000 divide_period (
        .clk        (clk),
        .rst_n      (rst_n),
        .numerator  (period_time),              // 被除数
        .quotient   (period_out)               // 商
    );

    // 周期二进制转BCD模块实例化
    Binary_to_BCD bcd_period_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (1),     // 周期除法完成信号
        .binary_in  (period_out),
        .bcd        (period_bcd),
        .done       (bcd_period_done)
    );

    // 周期BCD四舍五入模块实例化
    BCD_Rounding bcd_period_round_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (bcd_period_done),
        .BCD_in     (period_bcd),
        .BCD_out    (period_bcd_rounded),
        .done       (bcd_period_round_done)
    );

    
    wire freq_ten_tho_0 =(freq_bcd_rounded[19:16] == 0) ;
    wire freq_tho_0 =(freq_bcd_rounded[15:12] == 0) ;
    wire freq_hund_0 =(freq_bcd_rounded[11:8] == 0) ;
    wire freq_tens_0 =(freq_bcd_rounded[7:4] == 0) ;

    always @(*) begin
        Segment_freq = freq_bcd_rounded[19:4];
        point_1     = 2;
        k = 1'b1;
        casez ({freq_ten_tho_0, freq_tho_0, freq_hund_0, freq_tens_0})
            4'b1111: begin
                Segment_freq = freq_bcd_rounded[15:0];
                point_1     = 1'b0;
                k = 1'b0;
            end
            4'b111?: begin
                Segment_freq = freq_bcd_rounded[15:4];
                point_1     = 1'b0;
                k = 1'b0;
            end
            4'b11??: begin
                Segment_freq = freq_bcd_rounded[15:4];
                point_1     = 1'b0;
                k = 1'b0;
            end
            4'b1???: begin
                Segment_freq = freq_bcd_rounded[15:4];
                point_1     = 3;
            end
        endcase
    end

    wire period_ten_tho_0 =(period_bcd_rounded[19:16] == 0) ;
    wire period_tho_0 =(period_bcd_rounded[15:12] == 0) ;
    wire period_hund_0 =(period_bcd_rounded[11:8] == 0) ;
    wire period_tens_0 =(period_bcd_rounded[7:4] == 0) ;

    always @(*) begin
        Segment_period = period_bcd_rounded[19:4];
        point_2     = 2;
        k = 1'b1;
        casez ({period_ten_tho_0, period_tho_0, period_hund_0, period_tens_0})
            4'b1111: begin
                Segment_period = period_bcd_rounded[15:0];
                point_2     = 1'b0;
                k = 1'b0;
            end
            4'b111?: begin
                Segment_period = period_bcd_rounded[15:4];
                point_2     = 1'b0;
                k = 1'b0;
            end
            4'b11??: begin
                Segment_period = period_bcd_rounded[15:4];
                point_2     = 1'b0;
                k = 1'b0;
            end
            4'b1???: begin
                Segment_period = period_bcd_rounded[15:4];
                point_2     = 3;
            end
        endcase
    end
endmodule
