`timescale 1ns / 1ps

module tb_Binary_to_BCD;
    // 输入信号
    reg clk;
    reg rst_n;
    reg start;
    reg [31:0] binary_in;

    wire [23:0] bcd;
    wire done;

    // 实例化 Binary_to_BCD 模块
    Binary_to_BCD uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .binary_in(binary_in),
        .bcd(bcd),
        .done(done)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz 时钟
    end

    // 测试序列
    initial begin
        // 初始化
        rst_n = 0;
        start = 0;
        binary_in = 32'd0;
        #20;
        rst_n = 1;
        #10;

        // 测试用例1：输入123456
        binary_in = 32'd999999;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        // 测试完成
        #20;
        $finish;
    end

endmodule
