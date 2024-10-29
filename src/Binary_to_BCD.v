module Binary_to_BCD (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] binary_in,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] units,
    output reg done
    );

    // 定义转换的位数
    parameter NUM_BITS = 32;
    parameter BCD_DIGITS = 3;

    reg [NUM_BITS + BCD_DIGITS*4 -1:0] shift_reg; // 32 + 12 = 44 bits
    integer i;
    reg [4:0] count; // 0 to 32

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 0;
            hundreds <= 0;
            tens <= 0;
            units <= 0;
            count <= 0;
            done <= 0;
        end
        else if (start) begin
            // 初始化 shift_reg: binary_in followed by zeros for BCD digits
            shift_reg <= {binary_in, 12'd0};
            count <= 32;
            done <= 0;
        end
        else if (count > 0) begin
            // 每个时钟周期进行一次双拨法迭代
            // 检查每个 BCD 字位，如果 >=5则加3
            for (i = 0; i < BCD_DIGITS; i = i + 1) begin
                if (shift_reg[NUM_BITS + (i+1)*4 -1 -:4] >= 5)
                    shift_reg[NUM_BITS + (i+1)*4 -1 -:4] <= shift_reg[NUM_BITS + (i+1)*4 -1 -:4] + 3;
            end
            // 左移一位
            shift_reg <= {shift_reg[NUM_BITS + BCD_DIGITS*4 -2:0], 1'b0};
            count <= count - 1;
        end
        else if (!done) begin
            // 完成转换，提取 BCD 码
            hundreds <= shift_reg[NUM_BITS + 11 -:4];
            tens <= shift_reg[NUM_BITS + 7 -:4];
            units <= shift_reg[NUM_BITS + 3 -:4];
            done <= 1;
        end
        else begin
            // 保持输出
            done <= 0;
        end
    end

endmodule