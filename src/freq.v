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
    output reg [31:0] high_time,     // 高电平时间 (以系统时钟周期为单位)
    output reg [31:0] low_time,      // 低电平时间 (以系统时钟周期为单位)
    output wire [31:0] period_time,      // 周期时间 (以系统时钟周期为单位)
    output reg measurement_done      // 测量完成信号
);

    // 参数定义
    parameter CLOCK_FREQ = 50000000;  // 系统时钟频率，例如 50MHz

    // 同步输入信号，防止亚稳态
    reg [1:0] signal_sync;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_sync <= 2'b00;
        end
        else begin
            signal_sync <= {signal_sync[0], signal_in};
        end
    end

    wire signal_in_sync = signal_sync[1];

    // 边缘检测
    wire falling_edge = (signal_sync[1] & ~signal_sync[0]);
    wire rising_edge = (~signal_sync[1] & signal_sync[0]);

    // 状态机状态定义
    reg [2:0] IDLE = 3'd0;
    reg [2:0] WAIT_RISE = 3'd1;
    reg [2:0] COUNT_PERIOD = 3'd2;
    reg [2:0] MEASURE_HIGH = 3'd3;
    reg [2:0] MEASURE_LOW = 3'd4;

    reg [2:0] current_state, next_state;

    reg [31:0] counter;               // 用于计数系统时钟周期
    reg [31:0] period_count;          // 捕获到的周期计数
    reg [31:0] high_count;            // 高电平计数
    reg [31:0] low_count;             // 低电平计数

    assign period_time = period_count;
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
                if (rising_edge) begin
                    next_state = MEASURE_HIGH;
                end
                else begin
                    next_state = IDLE;
                end
            end
            MEASURE_HIGH: begin
                if (falling_edge) begin
                    next_state = MEASURE_LOW;
                end
                else begin
                    next_state = MEASURE_HIGH;
                end
            end
            MEASURE_LOW: begin
                if (rising_edge) begin
                    next_state = COUNT_PERIOD;
                end
                else begin
                    next_state = MEASURE_LOW;
                end
            end
            COUNT_PERIOD: begin
                if (rising_edge) begin
                    next_state = MEASURE_HIGH;
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
            counter <= 0;
            period_count <= 0;
            high_count <= 0;
            low_count <= 0;
            high_time <= 0;
            low_time <= 0;
            measurement_done <= 0;
        end
        else begin
            measurement_done <= 0; // 默认测量完成信号为低

            case (current_state)
                IDLE: begin
                    counter <= 0;
                    high_count <= 0;
                    low_count <= 0;
                end
                MEASURE_HIGH: begin
                    high_count <= 0;
                    low_count <= 0;
                end
                MEASURE_LOW: begin
                    low_count <= 0;
                end
                COUNT_PERIOD: begin
                    counter <= counter + 1;
                end
                default: ;
            endcase

            // 计数逻辑
            if (current_state == MEASURE_HIGH) begin
                high_count <= high_count + 1;
                counter <= counter + 1;
                if (falling_edge) begin
                    high_time <= high_count;
                end
            end
            else if (current_state == MEASURE_LOW) begin
                low_count <= low_count + 1;
                counter <= counter + 1;
                if (rising_edge) begin
                    low_time <= low_count;
                end
            end
            else if (current_state == COUNT_PERIOD) begin
                if (rising_edge) begin
                    period_count <= counter;
                    measurement_done <= 1;
                    counter <= 0;
                end
                else begin
                    counter <= counter + 1;
                end
            end
        end
    end

endmodule
