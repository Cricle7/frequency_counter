module Iterative_Divider (
    input        clk,
    input        rst_n,
    input        start,
    input  [31:0] numerator,    // 被除数
    input  [31:0] divisor,       // 除数
    output reg [31:0] quotient,  // 商
    output reg [31:0] remainder, // 余数
    output reg         done       // 完成信号
);
    reg [63:0] dividend;
    reg [31:0] divisor_reg;
    reg [5:0]  bit;
    reg        processing;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            quotient <= 32'd0;
            remainder <= 32'd0;
            dividend <= 64'd0;
            divisor_reg <= 32'd0;
            bit <= 6'd0;
            done <= 1'b0;
            processing <= 1'b0;
        end else if (start && !processing) begin
            divisor_reg <= divisor;
            dividend <= {32'd0, numerator};
            quotient <= 32'd0;
            bit <= 6'd32;
            done <= 1'b0;
            processing <= 1'b1;
        end else if (processing) begin
            if (bit > 0) begin
                dividend = dividend << 1;
                quotient = {quotient[30:0], dividend[63]};
                if (dividend[63:32] >= divisor_reg) begin
                    dividend[63:32] = dividend[63:32] - divisor_reg;
                    quotient[0] = 1'b1;
                end else begin
                    quotient[0] = 1'b0;
                end
                bit = bit - 1;
            end else begin
                remainder = dividend[63:32];
                done = 1'b1;
                processing = 1'b0;
            end
        end else begin
            done <= 1'b0;
        end
    end

endmodule
