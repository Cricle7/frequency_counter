module Pipelined_Divider (
    input wire clk,
    input wire rst,
    input wire start,                 // 开始除法操作
    input wire [31:0] dividend,       // 被除数
    input wire [31:0] divisor,        // 除数
    output reg [31:0] quotient,       // 商
    output reg ready                  // 除法结果就绪
);

    // 定义流水阶段的寄存器
    reg [31:0] dividend_reg [0:3];
    reg [31:0] divisor_reg [0:3];
    reg start_reg [0:3];
    
    integer i;
    
    // 每个时钟周期推进一个流水阶段
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                dividend_reg[i] <= 0;
                divisor_reg[i] <= 0;
                start_reg[i] <= 0;
            end
            quotient <= 0;
            ready <= 0;
        end
        else begin
            // 第一个阶段接收输入
            if (start) begin
                dividend_reg[0] <= dividend;
                divisor_reg[0] <= divisor;
                start_reg[0] <= 1;
            end
            else begin
                start_reg[0] <= 0;
            end
            
            // 后续阶段传递数据
            for (i = 1; i < 4; i = i + 1) begin
                dividend_reg[i] <= dividend_reg[i-1];
                divisor_reg[i] <= divisor_reg[i-1];
                start_reg[i] <= start_reg[i-1];
            end
            
            // 模拟除法操作，余数部分通过四舍五入的方式放到商的部分
            if (start_reg[3]) begin
                if (divisor_reg[3] != 0) begin
                    // 临时变量
                    reg [31:0] quotient_temp;
                    reg [31:0] remainder_temp;
                    
                    quotient_temp = dividend_reg[3] / divisor_reg[3];
                    
                    // 使用减法计算余数，避免使用取模运算
                    remainder_temp = dividend_reg[3] - (quotient_temp * divisor_reg[3]);
                    
                    // 判断是否需要进位
                    if (remainder_temp * 2 >= divisor_reg[3]) begin
                        quotient <= quotient_temp + 1;
                    end
                    else begin
                        quotient <= quotient_temp;
                    end
                end
                else begin
                    quotient <= 32'hFFFFFFFF; // 除以零时商为最大值
                end
                ready <= 1;
            end
            else begin
                ready <= 0;
            end
        end
    end

endmodule
