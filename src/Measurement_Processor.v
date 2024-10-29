module Measurement_Processor #(
    parameter CLOCK_FREQ = 50000000
)(
    input wire clk, // 系统时钟
    input wire rst, // 复位信号，高电平有效
    input wire measurement_done, // 测量完成信号
    input wire [31:0] high_time, // 高电平持续时间
    input wire [31:0] low_time, // 低电平持续时间
    input wire [31:0] period_time, // 信号周期 (秒)
    output reg [31:0] period, // 信号周期 (秒)
    output reg [31:0] frequency_out, // 计算得到的频率 (Hz)
    output reg calculation_done // 计算完成信号
);

    // 内部信号
    reg [31:0] period_reg;
    reg [31:0] divider_dividend;
    reg [31:0] divider_divisor;
    reg divider_start;
    wire [31:0] divider_quotient;
    wire divider_ready;

    // 实例化一个 Pipelined_Divider
    Pipelined_Divider divider_inst (
        .clk(clk),
        .rst(rst),
        .start(divider_start),
        .dividend(divider_dividend),
        .divisor(divider_divisor),
        .quotient(divider_quotient),
        .ready(divider_ready)
    );

    // 状态机定义
    reg [2:0] current_state, next_state;
    localparam IDLE       = 3'd0;
    localparam LOAD       = 3'd1;
    localparam CALC_FREQ  = 3'd2;
    localparam WAIT_FREQ  = 3'd3;
    localparam CALC_PER   = 3'd4;
    localparam WAIT_PER   = 3'd5;
    localparam OUTPUT     = 3'd6;

    // 状态转移
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // 状态机逻辑
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (measurement_done) begin
                    next_state = LOAD;
                end else begin
                    next_state = IDLE;
                end
            end
            LOAD: begin
                next_state = CALC_FREQ;
            end
            CALC_FREQ: begin
                next_state = WAIT_FREQ;
            end
            WAIT_FREQ: begin
                if (divider_ready) begin
                    next_state = CALC_PER;
                end else begin
                    next_state = WAIT_FREQ;
                end
            end
            CALC_PER: begin
                next_state = WAIT_PER;
            end
            WAIT_PER: begin
                if (divider_ready) begin
                    next_state = OUTPUT;
                end else begin
                    next_state = WAIT_PER;
                end
            end
            OUTPUT: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // 控制信号和输出逻辑
    reg [31:0] frequency_temp; // 暂存频率计算结果

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            period <= 0;
            frequency_out <= 0;
            calculation_done <= 0;
            divider_start <= 0;
            divider_dividend <= 0;
            divider_divisor <= 0;
            period_reg <= 0;
            frequency_temp <= 0;
        end else begin
            calculation_done <= 0; // 每个时钟周期复位计算完成信号
            divider_start <= 0;    // 默认不启动除法器

            case (current_state)
                IDLE: begin
                    // 等待 measurement_done 信号
                end
                LOAD: begin
                    // 计算周期时间
                    period_reg <= high_time + low_time;
                end
                CALC_FREQ: begin
                    // 准备第一个除法操作：计算频率
                    divider_dividend <= CLOCK_FREQ;     // 被除数：时钟频率
                    divider_divisor <= period_reg;      // 除数：信号周期时间
                    divider_start <= 1;                 // 启动除法器
                end
                WAIT_FREQ: begin
                    // 等待除法器完成计算
                    if (divider_ready) begin
                        frequency_temp <= divider_quotient; // 保存频率计算结果
                    end
                end
                CALC_PER: begin
                    // 准备第二个除法操作：计算周期
                    divider_dividend <= period_reg;     // 被除数：信号周期时间
                    divider_divisor <= CLOCK_FREQ;      // 除数：时钟频率
                    divider_start <= 1;                 // 启动除法器
                end
                WAIT_PER: begin
                    // 等待除法器完成计算
                    if (divider_ready) begin
                        period <= divider_quotient;     // 获取周期计算结果
                    end
                end
                OUTPUT: begin
                    frequency_out <= frequency_temp;    // 输出频率结果
                    calculation_done <= 1;              // 设置计算完成信号
                end
                default: ;
            endcase
        end
    end
endmodule
