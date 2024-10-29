module Sampling_Module (
    input wire clk,              // 系统时钟
    input wire rst,              // 复位信号，高电平有效
    input wire sample_enable,    // 采样使能信号
    input wire [15:0] data_in,   // 输入数据（假设为16位）
    output reg [15:0] data_out,  // 输出采样数据
    output reg sample_ready      // 采样完成信号
);

    parameter SAMPLE_RATE = 1000000; // 采样率，例如1MHz
    parameter CLOCK_FREQ = 50000000; // 时钟频率，例如50MHz

    // 计算分频计数
    localparam integer COUNT_MAX = CLOCK_FREQ / SAMPLE_RATE;

    reg [31:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            data_out <= 0;
            sample_ready <= 0;
        end
        else if (sample_enable) begin
            if (counter < COUNT_MAX - 1) begin
                counter <= counter + 1;
                sample_ready <= 0;
            end
            else begin
                counter <= 0;
                data_out <= data_in;    // 采样输入数据
                sample_ready <= 1;      // 采样完成信号置高
            end
        end
        else begin
            counter <= 0;
            sample_ready <= 0;
        end
    end

endmodule

module Input_Capture_Module (
    input wire clk,                  // 系统时钟 (例如 50MHz)
    input wire rst,                  // 复位信号，高电平有效
    input wire signal_in,            // 待测量的输入信号
    output reg [31:0] frequency,     // 测量得到的频率 (Hz)
    output reg measurement_done      // 测量完成信号
);

    // 状态机状态定义
    wire [1:0] IDLE         = 2'd0;
    wire [1:0] WAIT_RISE    = 2'd1;
    wire [1:0] COUNT_PERIOD = 2'd2;

    reg [1:0] current_state, next_state;

    reg signal_in_prev;               // 前一个时钟周期的输入信号，用于边缘检测
    reg [31:0] counter;               // 用于计数系统时钟周期
    reg [31:0] period_count;          // 捕获到的周期计数

    // 参数定义
    parameter CLOCK_FREQ = 50000000;  // 系统时钟频率，例如 50MHz

    // 状态转移
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    // 状态机逻辑
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (signal_in && !signal_in_prev) begin
                    next_state = WAIT_RISE;
                end
                else begin
                    next_state = IDLE;
                end
            end
            WAIT_RISE: begin
                if (signal_in && !signal_in_prev) begin
                    next_state = COUNT_PERIOD;
                end
                else begin
                    next_state = WAIT_RISE;
                end
            end
            COUNT_PERIOD: begin
                if (signal_in && !signal_in_prev) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = COUNT_PERIOD;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // 边缘检测和计数逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_in_prev <= 0;
            counter <= 0;
            period_count <= 0;
            frequency <= 0;
            measurement_done <= 0;
        end
        else begin
            signal_in_prev <= signal_in;
            measurement_done <= 0;

            case (current_state)
                IDLE: begin
                    counter <= 0;
                end
                WAIT_RISE: begin
                    counter <= 0;
                end
                COUNT_PERIOD: begin
                    counter <= counter + 1;
                    if (signal_in && !signal_in_prev) begin
                        period_count <= counter;
                        frequency <= CLOCK_FREQ / counter;
                        measurement_done <= 1;
                        counter <= 0;
                    end
                end
            endcase
        end
    end

endmodule