`timescale 1ns / 1ps

module tb_Top_Module;

    // 参数定义
    parameter CLOCK_FREQ = 50000000; // 系统时钟频率 50MHz
    parameter CLOCK_PERIOD = 20;     // 时钟周期 20ns (50MHz)

    // 信号声明
    reg clk;
    reg rst;
    reg signal_in;
    reg [31:0] clock_freq;
    wire [6:0] seg_freq;
    wire [2:0] an_freq;
    wire [6:0] seg_period;
    wire [2:0] an_period;
    wire [6:0] seg_pulse;
    wire [2:0] an_pulse;

    // 实例化顶层模块
    Top_Module uut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .clock_freq(clock_freq),
        .seg_freq(seg_freq),
        .an_freq(an_freq),
        .seg_period(seg_period),
        .an_period(an_period),
        .seg_pulse(seg_pulse),
        .an_pulse(an_pulse)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    // 输入信号生成
    initial begin
        // 初始化信号
        rst = 1;
        signal_in = 0;
        clock_freq = CLOCK_FREQ;
        #100; // 100ns 复位
        rst = 0;

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

    // 监视数码管显示（仿真时打印信号状态）
    // 注意：在实际 FPGA 中，数码管的显示需要通过硬件观察，这里仅为仿真打印。
    initial begin
        $monitor("Time: %0t | Seg_Freq: %b | Seg_Period: %b | Seg_Pulse: %b | AN_Freq: %b | AN_Period: %b | AN_Pulse: %b",
                 $time, seg_freq, seg_period, seg_pulse, an_freq, an_period, an_pulse);
    end

endmodule
