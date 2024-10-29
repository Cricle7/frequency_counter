`timescale 1ns / 1ps

module tb_Top_Module;

    // 参数定义
    parameter CLOCK_FREQ = 50000000; // 系统时钟频率 50MHz
    parameter CLOCK_PERIOD = 20;     // 时钟周期 20ns (50MHz)

    // 信号声明
    reg clk;
    reg rst_n;
    reg signal_in;
    wire rclk;
    wire sclk;
    wire dio;  
    // 实例化顶层模块
    Top_Module uut (
        .clk(clk),
        .rst_n(rst),
        .signal_in(signal_in),
        .rclk(rclk),
        .sclk(sclk),
        .dio(dio)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    // 输入信号生成
    initial begin
        // 初始化信号
        rst = 0;
        signal_in = 0;
        #100; // 100ns 复位
        rst = 1;

        // 等待一段时间后开始信号生成
        #1000;

        // 1Hz，50% 占空比
        repeat(2) begin
            signal_in = 1;
            #(50000000) signal_in = 0; // 高电平持续0.5秒
            #(50000000);               // 低电平持续0.5秒
        end

        // 10Hz，70% 占空比
        repeat(2) begin
            signal_in = 1;
            #(70000000) signal_in = 0;  // 高电平持续0.7秒
            #(30000000);               // 低电平持续0.3秒
        end

        // 20Hz，30% 占空比
        repeat(2) begin
            signal_in = 1;
            #(30000000) signal_in = 0;  // 高电平持续0.3秒
            #(70000000);               // 低电平持续0.7秒
        end

        // 50Hz，50% 占空比
        repeat(2) begin
            signal_in = 1;
            #(20000000) signal_in = 0;  // 高电平持续0.2秒
            #(20000000);               // 低电平持续0.2秒
        end

        // 结束仿真
        #100000000;
        $stop;
    end

endmodule
