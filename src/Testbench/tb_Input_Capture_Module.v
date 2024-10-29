module tb_Input_Capture_Module;

    // 参数定义
    parameter CLOCK_PERIOD = 20; // 50MHz 时钟周期为 20ns

    // 信号声明
    reg clk;
    reg rst;
    reg signal_in;
    wire [31:0] frequency;
    wire measurement_done;

    // 实例化被测模块
    Input_Capture_Module uut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .frequency(frequency),
        .measurement_done(measurement_done)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    // 输入信号生成 (10Hz)
    initial begin
        rst = 1;
        signal_in = 0;
        #100;
        rst = 0;
        forever begin
            #50000000 signal_in = ~signal_in; // 50,000,000 ns = 1s周期 (1Hz)
            // 修改为 100,000,000 ns = 2s周期 (0.5Hz) 等以生成不同频率
        end
    end

    // 监视信号
    initial begin
        $monitor("Time: %0t | Frequency: %d Hz | Measurement Done: %b", $time, frequency, measurement_done);
    end

endmodule