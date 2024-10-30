`timescale 1ns / 1ps

module tb_Iterative_Divider;

    // 输入信号
    reg clk;
    reg rst_n;
    reg start;
    reg [31:0] numerator;
    reg [31:0] divisor;

    // 输出信号
    wire [31:0] quotient;
    wire [31:0] remainder;
    wire done;

    // 实例化 Iterative_Divider 模块
    Iterative_Divider uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .numerator(numerator),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done)
    );

    // 时钟生成：周期为10ns (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        start = 0;
        numerator = 32'd0;
        divisor = 32'd1;
        #20; // 等待20ns

        // 释放复位
        rst_n = 1;
        #10;

        // 测试用例1：被除数 = 100, 除数 = 10
        numerator = 32'd100;
        divisor = 32'd10;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 1: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例2：被除数 = 123456, 除数 = 123
        numerator = 32'd123456;
        divisor = 32'd123;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 2: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例3：被除数 = 65535, 除数 = 1
        numerator = 32'd65535;
        divisor = 32'd1;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 3: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例4：被除数 = 0, 除数 = 12345
        numerator = 32'd0;
        divisor = 32'd12345;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 4: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例5：被除数 = 4294967295 (最大32位无符号数), 除数 = 65535
        numerator = 32'd4294967295;
        divisor = 32'd65535;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 5: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例6：被除数 = 1000, 除数 = 3
        numerator = 32'd1000;
        divisor = 32'd3;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 6: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例7：被除数 = 50000000, 除数 = 5000
        numerator = 32'd50000000;
        divisor = 32'd5000;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 7: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例8：被除数 = 50,000,000, 除数 = 7
        numerator = 32'd50000000;
        divisor = 32'd7;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 8: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例9：被除数 = 50000000, 除数 = 50000000 (被除数等于除数)
        numerator = 32'd50000000;
        divisor = 32'd50000000;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Test 9: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);

        // 测试用例10：被除数 = 50000000, 除数 = 0 (除数为零，需处理)
        numerator = 32'd50000000;
        divisor = 32'd0;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        if (divisor == 32'd0) begin
            $display("Test 10: %d / %d = Undefined (Division by Zero)", numerator, divisor);
        end else begin
            $display("Test 10: %d / %d = %d, Remainder = %d", numerator, divisor, quotient, remainder);
        end

        // 测试完成
        #20;
        $finish;
    end

endmodule
