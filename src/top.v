`timescale 1ns / 1ps
//+------------------+        +-----------------------+
//| Input_Capture    |        | Measurement_Processor |
//| Module           |        |                       |
//|                  |        |                       |
//| signal_in ------>+--------> frequency             |
//|                  |        | high_time             |
//|                  |        | low_time              |
//|                  |        | measurement_done ---->+------+
//|                  |        |                       |      |
//+------------------+        +-----------------------+      |
                                                           //|
                                                           //|
//+-----------------+                                       |
//| Top_Module      |                                       |
//|                 |                                       |
//| clk --------->--+                                       |
//| rst --------->--+                                       |
//| signal_in ------+                                       |
//| clock_freq ----->                                       |
//| measured_freq <--+                                       |
//| measured_period <-+                                      |
//| calculation_done <--+                                   |
//+-----------------+                                       |
                                                           //|
                                                           //|
//+---------------------+                                    |
//| (其他外部接口，如 UART, SPI 等) <------------------------+
//+---------------------+
module Top_Module (
    input wire clk,                      // 系统时钟
    input wire rst,                      // 复位信号，高电平有效
    input wire signal_in,                // 待测量的输入信号
    // 数码管输出
//    output wire [6:0] seg_freq,          // 频率数码管段选
    //output wire [2:0] an_freq,           // 频率数码管位选
    //output wire [6:0] seg_period,        // 周期数码管段选
    //output wire [2:0] an_period,         // 周期数码管位选
    //output wire [6:0] seg_pulse,         // 脉宽数码管段选
    //output wire [2:0] an_pulse,           // 脉宽数码管位选
    output              rclk,
    output              sclk,
    output              dio
    );

    parameter CLOCK_FREQ = 50000000;
    parameter SCAN_FREQ  = 1000;
    // 中间信号
    wire [31:0] period_time;
    wire [31:0] high_time;
    wire [31:0] low_time;
    wire measurement_done_sig;

    wire [31:0] period;
    wire [31:0] frequency_out;
    wire calculation_done;

    // BCD转换器输出
    wire [3:0] freq_hundreds, freq_tens, freq_units;
    wire [3:0] period_hundreds, period_tens, period_units;
    wire [3:0] pulse_hundreds, pulse_tens, pulse_units;

    wire bcd_freq_done, bcd_period_done, bcd_pulse_done;
    wire [3:0]digit0 = 0;
    wire [3:0]digit1 = 1;
    wire [3:0]digit2 = 2;
    wire [3:0]digit3 = 3;
    wire [3:0]digit4 = 4;
    wire [3:0]digit5 = 5;
    wire [3:0]digit6 = 6;
    wire [3:0]digit7 = 7;
    wire dp0    = 1;
    wire dp1    = 0;
    wire dp2    = 1;
    wire dp3    = 0;
    wire dp4    = 1;
    wire dp5    = 0;
    wire dp6    = 1;
    wire dp7    = 0;
    // 小数点控制信号（示例：在小数点位置显示测量精度）
    wire dp_freq, dp_period, dp_pulse;

    // 实例化 Input_Capture_Module
    Input_Capture_Module capture_inst (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .high_time(high_time),
        .low_time(low_time),
        .period_time(period_time),
        .measurement_done(measurement_done_sig)
    );

    // 实例化 Measurement_Processor
    Measurement_Processor # (
        .CLOCK_FREQ(CLOCK_FREQ)
    ) processor(
        .clk(clk),
        .rst(rst),
        .measurement_done(measurement_done_sig),
        .high_time(high_time),
        .low_time(low_time),
        .period_time(period_time),
        .period(period),
        .frequency_out(frequency_out),
        .calculation_done(calculation_done)
    );

    // 实例化 Binary_to_BCD 转换器用于频率
    Binary_to_BCD bcd_freq (
        .clk(clk),
        .rst(rst),
        .start(calculation_done),
        .binary_in(frequency_out),
        .hundreds(freq_hundreds),
        .tens(freq_tens),
        .units(freq_units),
        .done(bcd_freq_done)
    );

    // 实例化 Binary_to_BCD 转换器用于周期
    Binary_to_BCD bcd_period (
        .clk(clk),
        .rst(rst),
        .start(calculation_done),
        .binary_in(period),
        .hundreds(period_hundreds),
        .tens(period_tens),
        .units(period_units),
        .done(bcd_period_done)
    );

    // 实例化 Binary_to_BCD 转换器用于脉宽
    Binary_to_BCD bcd_pulse (
        .clk(clk),
        .rst(rst),
        .start(calculation_done),
        .binary_in(high_time), // 假设脉宽为 high_time
        .hundreds(pulse_hundreds),
        .tens(pulse_tens),
        .units(pulse_units),
        .done(bcd_pulse_done)
    );

    // 生成小数点控制信号（示例：根据具体需求设置）
    assign dp_freq = 1;    // 固定显示小数点
    assign dp_period = 1;  // 固定显示小数点
    assign dp_pulse = 1;   // 固定显示小数点

    Seven_Segment_Display #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .SCAN_FREQ(SCAN_FREQ)
    ) uut (
        .clk(clk),
        .rst(rst),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .digit4(digit4),
        .digit5(digit5),
        .digit6(digit6),
        .digit7(digit7),
        .dp0(dp0),
        .dp1(dp1),
        .dp2(dp2),
        .dp3(dp3),
        .dp4(dp4),
        .dp5(dp5),
        .dp6(dp6),
        .dp7(dp7),
        .dio(dio),
        .rclk(rclk),
        .sclk(sclk)
    );
    // 实例化 Seven_Segment_Display 用于频率
//    Seven_Segment_Display display_freq (
        //.clk(clk),
        //.rst(rst),
        //.hundreds(freq_hundreds),
        //.tens(freq_tens),
        //.units(freq_units),
        //.dp_hundreds(dp_freq),
        //.dp_tens(dp_freq),
        //.dp_units(dp_freq),
        //.seg(seg_freq),
        //.an(an_freq)
    //);

    //// 实例化 Seven_Segment_Display 用于周期
    //Seven_Segment_Display display_period (
        //.clk(clk),
        //.rst(rst),
        //.hundreds(period_hundreds),
        //.tens(period_tens),
        //.units(period_units),
        //.dp_hundreds(dp_period),
        //.dp_tens(dp_period),
        //.dp_units(dp_period),
        //.seg(seg_period),
        //.an(an_period)
    //);

    //// 实例化 Seven_Segment_Display 用于脉宽
    //Seven_Segment_Display display_pulse (
        //.clk(clk),
        //.rst(rst),
        //.hundreds(pulse_hundreds),
        //.tens(pulse_tens),
        //.units(pulse_units),
        //.dp_hundreds(dp_pulse),
        //.dp_tens(dp_pulse),
        //.dp_units(dp_pulse),
        //.seg(seg_pulse),
        //.an(an_pulse)
    //);

endmodule
