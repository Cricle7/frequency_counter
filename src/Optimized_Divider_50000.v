module Pipelined_Optimized_Divider_5000 (
    input               clk,
    input               rst_n,
    input       [31:0]  numerator,      // 被除数
    output  reg [31:0]  quotient        // 商
);
    // 预计算的倒数乘以 2^32
    localparam RECIPROCAL = 32'd1717987; // 1 / 5,000 * 2^32 ≈ 1717986.9184

    reg [31:0] numerator_reg;
    reg [31:0] reciprocal_reg;
    reg [63:0] product_reg;
    reg        is_zero_reg;

    wire is_zero;

    // 检测被除数是否为零
    assign is_zero = (numerator == 32'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            numerator_reg  <= 32'd0;
            reciprocal_reg <= 32'd0;
            product_reg    <= 64'd0;
            is_zero_reg    <= 1'b0;
            quotient       <= 32'd0;
        end else begin
            // 流水线阶段1：寄存被除数和倒数
            numerator_reg  <= numerator;
            reciprocal_reg <= RECIPROCAL;
            is_zero_reg    <= is_zero;

            // 流水线阶段2：乘法
            product_reg <= (numerator_reg * reciprocal_reg);

            // 流水线阶段3：输出商
            if (is_zero_reg)
                quotient <= 32'd0;
            else
                quotient <= product_reg[63:32]; // 右移32位
        end
    end
endmodule
