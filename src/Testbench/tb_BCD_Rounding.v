`timescale 1ns / 1ps

module tb_BCD_Rounding;
    // 输入信号
    reg clk;
    reg rst_n;
    reg start;
    reg [3:0] hundred_thousands_in;
    reg [3:0] ten_thousands_in;
    reg [3:0] thousands_in;
    reg [3:0] hundreds_in;
    reg [3:0] tens_in;
    reg [3:0] units_in;

    // 输出信号
    wire [3:0] hundred_thousands_out;
    wire [3:0] ten_thousands_out;
    wire [3:0] thousands_out;
    wire [3:0] hundreds_out;
    wire [3:0] tens_out;
    wire [3:0] units_out;
    wire done;

    // 实例化 BCD_Rounding 模块
    BCD_Rounding uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .hundred_thousands_in(hundred_thousands_in),
        .ten_thousands_in(ten_thousands_in),
        .thousands_in(thousands_in),
        .hundreds_in(hundreds_in),
        .tens_in(tens_in),
        .units_in(units_in),
        .hundred_thousands_out(hundred_thousands_out),
        .ten_thousands_out(ten_thousands_out),
        .thousands_out(thousands_out),
        .hundreds_out(hundreds_out),
        .tens_out(tens_out),
        .units_out(units_out),
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
        {hundred_thousands_in, ten_thousands_in, thousands_in, hundreds_in, tens_in, units_in} = 24'd0;
        #20;
        rst_n = 1;
        #10;

        // 测试用例1：输入 123456，units 位小于 5，不需要进位
        hundred_thousands_in = 4'd0;
        ten_thousands_in     = 4'd1;
        thousands_in         = 4'd2;
        hundreds_in          = 4'd3;
        tens_in              = 4'd4;
        units_in             = 4'd5;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("BCD_Rounding Test 1: Input BCD = %d%d%d%d%d%d, Output BCD = %d%d%d%d%d%d",
                 hundred_thousands_in, ten_thousands_in, thousands_in, hundreds_in, tens_in, units_in,
                 hundred_thousands_out, ten_thousands_out, thousands_out, hundreds_out, tens_out, units_out);

        // 测试用例2：输入 123457，units 位大于等于 5，需要进位
        units_in = 4'd7;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("BCD_Rounding Test 2: Input BCD = %d%d%d%d%d%d, Output BCD = %d%d%d%d%d%d",
                 hundred_thousands_in, ten_thousands_in, thousands_in, hundreds_in, tens_in, units_in,
                 hundred_thousands_out, ten_thousands_out, thousands_out, hundreds_out, tens_out, units_out);

        // 测试完成
        #20;
        $finish;
    end

endmodule
