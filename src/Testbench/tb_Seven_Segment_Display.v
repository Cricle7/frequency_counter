`timescale 1ns / 1ps

module tb_Seven_Segment_Display;

    // 参数定义
    parameter CLOCK_FREQ = 50000000;    // 50 MHz
    parameter SCAN_FREQ  = 1000;        // 1 kHz

    // 输入信号
    reg clk;
    reg rst;
    reg [3:0] digit0;
    reg [3:0] digit1;
    reg [3:0] digit2;
    reg [3:0] digit3;
    reg [3:0] digit4;
    reg [3:0] digit5;
    reg [3:0] digit6;
    reg [3:0] digit7;
    reg dp0;
    reg dp1;
    reg dp2;
    reg dp3;
    reg dp4;
    reg dp5;
    reg dp6;
    reg dp7;

    // 输出信号
    wire dio;
    wire rclk;
    wire sclk;

    // 实例化被测模块 (DUT: Device Under Test)
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

    // 时钟生成：周期为 20ns（50MHz）
    initial begin
        clk = 0;
        forever #(10) clk = ~clk; // 50MHz 时钟
    end

    // 初始化输入信号并应用测试数据
    initial begin
        // 初始化所有输入为0
        rst     = 1;
        digit0  = 4'd0;
        digit1  = 4'd0;
        digit2  = 4'd0;
        digit3  = 4'd0;
        digit4  = 4'd0;
        digit5  = 4'd0;
        digit6  = 4'd0;
        digit7  = 4'd0;
        dp0     = 1'b0;
        dp1     = 1'b0;
        dp2     = 1'b0;
        dp3     = 1'b0;
        dp4     = 1'b0;
        dp5     = 1'b0;
        dp6     = 1'b0;
        dp7     = 1'b0;

        // 复位信号保持一段时间
        #(100) rst = 0; // 100ns 后释放复位

        // 等待一段时间后应用第一组测试数据
        #(1000);

        // 应用第一组测试数据
        digit0  = 4'd1;
        digit1  = 4'd2;
        digit2  = 4'd3;
        digit3  = 4'd4;
        digit4  = 4'd5;
        digit5  = 4'd6;
        digit6  = 4'd7;
        digit7  = 4'd8;
        dp0     = 1'b0;
        dp1     = 1'b1; // 第1位小数点点亮
        dp2     = 1'b0;
        dp3     = 1'b1; // 第3位小数点点亮
        dp4     = 1'b0;
        dp5     = 1'b1; // 第5位小数点点亮
        dp6     = 1'b0;
        dp7     = 1'b1; // 第7位小数点点亮

        // 等待一段时间后应用第二组测试数据
        #(10000);

        // 应用第二组测试数据
        digit0  = 4'd9;
        digit1  = 4'd8;
        digit2  = 4'd7;
        digit3  = 4'd6;
        digit4  = 4'd5;
        digit5  = 4'd4;
        digit6  = 4'd3;
        digit7  = 4'd2;
        dp0     = 1'b1; // 第0位小数点点亮
        dp1     = 1'b0;
        dp2     = 1'b1; // 第2位小数点点亮
        dp3     = 1'b0;
        dp4     = 1'b1; // 第4位小数点点亮
        dp5     = 1'b0;
        dp6     = 1'b1; // 第6位小数点点亮
        dp7     = 1'b0;

        // 等待足够时间以完成所有扫描周期
        #(100000);

        // 结束仿真
        $finish;
    end

    // 监控输出信号
    initial begin
        $monitor("Time=%0dns | rst=%b | dio=%b | rclk=%b | sclk=%b | digits=%d%d%d%d%d%d%d%d | dp=%b%b%b%b%b%b%b%b",
                 $time, rst, dio, rclk, sclk,
                 digit7, digit6, digit5, digit4, digit3, digit2, digit1, digit0,
                 dp7, dp6, dp5, dp4, dp3, dp2, dp1, dp0);
    end

    // 可选：记录输出信号到文件
    initial begin
        $dumpfile("Seven_Segment_Display_tb.vcd");
        $dumpvars(0, tb_Seven_Segment_Display);
    end

endmodule
