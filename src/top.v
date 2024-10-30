`timescale 1ns / 1ps
//+------------------+        +-----------------------+
//| Input_Capture    |        | Measurement_Processor |
//| Module           |        |                       |
//|                  |        |                       |
//| signal_in ------>+--------> frequency             |
//|                  |        | high_time             |
//|                  |        | low_time              |
//|                  |        | measurement_done ---->+------+
//|                  |        |                       |      |
//+------------------+        +-----------------------+      |
                                                           //|
                                                           //|
//+-----------------+                                       |
//| Top_Module      |                                       |
//|                 |                                       |
//| clk --------->--+                                       |
//| rst --------->--+                                       |
//| signal_in ------+                                       |
//| clock_freq ----->                                       |
//| measured_freq <--+                                       |
//| measured_period <-+                                      |
//| calculation_done <--+                                   |
//+-----------------+                                       |
                                                           //|
                                                           //|
//+---------------------+                                    |
//| (其他外部接口，如 UART, SPI 等) <------------------------+
//+---------------------+
module Top_Module (
    input wire clk,                      // 系统时钟
    input wire rst_n,                      // 复位信号，高电平有效
    input wire signal_in,                // 待测量的输入信号
    input wire mod_sel,                   // 按键
    output              rclk,
    output              sclk,
    output              dio,
    output              k,
    output              m
    );

    parameter CLOCK_FREQ = 50000000;
    parameter SCAN_FREQ  = 1000;
    // 中间信号
    wire [31:0] period_time;
    wire [31:0] Measurement_time;
    wire [31:0] high_time;
    wire [31:0] low_time;
    wire measurement_done_sig;

    wire [15:0] Segment_freq   ;
    wire [15:0] Segment_period ;
    wire [2:0] point_1        ;
    wire [2:0] point_2        ;
    // 小数点控制信号（示例：在小数点位置显示测量精度）
    wire dp_freq, dp_period, dp_pulse;
    reg [1:0] sig_in_r;

    reg [1:0] mod_sel_r;                   // 按键
    always @(posedge clk) begin
        sig_in_r <= {sig_in_r,signal_in};
        mod_sel_r <= {mod_sel_r,mod_sel};
    end
    assign Measurement_time = mod_sel_r[1] ? period_time : high_time;
    Input_Capture_Module capture_inst (
        .clk               (clk               ),
        .rst               (!rst_n            ),
        .signal_in         (sig_in_r[1]       ),
        .high_time         (high_time         ),
        .low_time          (low_time          ),
        .period_time       (period_time       ),
        .measurement_done  (measurement_done_sig)
    );

    // 实例化 Measurement_Processor
    Measurement_Processor # (
        .CLOCK_FREQ        (CLOCK_FREQ        )
    ) processor (
        .clk               (clk               ),
        .rst_n             (rst_n             ),
        .measurement_done  (measurement_done_sig),
        .period_time       (Measurement_time  ),
        .Segment_freq      (Segment_freq      ),
        .Segment_period    (Segment_period    ),
        .point_1           (point_1           ),
        .point_2           (point_2           ),
        .k                 (k                 ),
        .m                 (m                 )
    );

    hex8_test u_hex8_test (
        .Clk         (clk               ),
        .Reset_n     (rst_n             ),
        .point_1     (point_1           ),
        .point_2     (point_2           ),
        .Disp_Data   ({Segment_freq,Segment_period}),
        .SH_CP       (sclk              ),
        .ST_CP       (rclk              ),
        .DS          (dio               )
    );

endmodule
