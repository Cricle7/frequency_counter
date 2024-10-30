`timescale 1ns / 1ps

module tb_Input_Capture_Module;

    // 参数定义
    parameter CLOCK_FREQ = 50000000; // 系统时钟频率 50MHz
    parameter CLOCK_PERIOD = 20;     // 时钟周期 20ns (50MHz)

    // 信号声明
    reg clk;
    reg rst;
    reg signal_in;
    wire [31:0] frequency;
    wire [31:0] high_time;
    wire [31:0] low_time;
    wire [31:0] period_time;
    wire measurement_done;

    // 实例化被测模块
    Input_Capture_Module uut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .high_time(high_time),
        .low_time(low_time),
        .period_time(period_time),
        .measurement_done(measurement_done)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    initial begin
        // 初始复位
        signal_in = 0;
        rst = 1;
        #100;
        rst = 0;

        // 1Hz 测试
        #1000; // 等待 1us
        repeat(4) begin
            #50000000 signal_in = ~signal_in; // 1Hz
        end

        // 停止 1Hz 信号
        #1000;

        // 10Hz 测试
        repeat(20) begin
            #5000000 signal_in = ~signal_in; // 10Hz
        end

        // 停止 10Hz 信号
        #1000;

        // 20Hz 测试
        repeat(40) begin
            #2500000 signal_in = ~signal_in; // 20Hz
        end

        // 停止 20Hz 信号
        #1000;

        // 50Hz 测试
        repeat(100) begin
            #1000000 signal_in = ~signal_in; // 50Hz
        end

        // 结束仿真
        $stop;
    end

    // 监视信号
    initial begin
        $monitor("Time: %0t | Frequency: %d Hz | Measurement Done: %b", $time, frequency, measurement_done);
    end

endmodule