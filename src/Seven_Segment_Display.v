module Seven_Segment_Display #(
    parameter CLOCK_FREQ = 50000000,    // 系统时钟频率，默认为 50 MHz
    parameter SCAN_FREQ  = 1000         // 扫描频率，默认为 1 kHz
)(
    input                               clk,
    input                               rst_n,

    // 输入 BCD 数据
    input       [3:0]                   freq_hundreds,
    input       [3:0]                   freq_tens,
    input       [3:0]                   freq_units,

    input       [3:0]                   period_hundreds,
    input       [3:0]                   period_tens,
    input       [3:0]                   period_units,

    input       [3:0]                   pulse_hundreds,
    input       [3:0]                   pulse_tens,
    input       [3:0]                   pulse_units,

    // 输出显示数据
    output      [31:0]                  Disp_Data
);

    // 内部信号
    wire [6:0] seg_freq_hundreds;
    wire [6:0] seg_freq_tens;
    wire [6:0] seg_freq_units;

    wire [6:0] seg_period_hundreds;
    wire [6:0] seg_period_tens;
    wire [6:0] seg_period_units;

    wire [6:0] seg_pulse_hundreds;
    wire [6:0] seg_pulse_tens;
    wire [6:0] seg_pulse_units;

    // BCD 转 7 段显示编码
    BCD_to_SevenSegment bcd_freq_hundreds_inst (
        .bcd   (freq_hundreds),
        .seg   (seg_freq_hundreds)
    );

    BCD_to_SevenSegment bcd_freq_tens_inst (
        .bcd   (freq_tens),
        .seg   (seg_freq_tens)
    );

    BCD_to_SevenSegment bcd_freq_units_inst (
        .bcd   (freq_units),
        .seg   (seg_freq_units)
    );

    BCD_to_SevenSegment bcd_period_hundreds_inst (
        .bcd   (period_hundreds),
        .seg   (seg_period_hundreds)
    );

    BCD_to_SevenSegment bcd_period_tens_inst (
        .bcd   (period_tens),
        .seg   (seg_period_tens)
    );

    BCD_to_SevenSegment bcd_period_units_inst (
        .bcd   (period_units),
        .seg   (seg_period_units)
    );

    BCD_to_SevenSegment bcd_pulse_hundreds_inst (
        .bcd   (pulse_hundreds),
        .seg   (seg_pulse_hundreds)
    );

    BCD_to_SevenSegment bcd_pulse_tens_inst (
        .bcd   (pulse_tens),
        .seg   (seg_pulse_tens)
    );

    BCD_to_SevenSegment bcd_pulse_units_inst (
        .bcd   (pulse_units),
        .seg   (seg_pulse_units)
    );

    // 将所有7段显示编码打包到Disp_Data
    assign Disp_Data = {
        seg_pulse_units,      // [31:28]
        seg_pulse_tens,       // [27:24]
        seg_pulse_hundreds,   // [23:20]
        seg_period_units,     // [19:16]
        seg_period_tens,      // [15:12]
        seg_period_hundreds,  // [11:8]
        seg_freq_units,       // [7:4]
        seg_freq_tens         // [3:0]
        // 可以根据需要添加更多位
    };

endmodule

// BCD 到 7 段显示编码模块
module BCD_to_SevenSegment (
    input       [3:0]                   bcd,
    output reg  [6:0]                   seg
);
    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b0111111;
            4'd1: seg = 7'b0000110;
            4'd2: seg = 7'b1011011;
            4'd3: seg = 7'b1001111;
            4'd4: seg = 7'b1100110;
            4'd5: seg = 7'b1101101;
            4'd6: seg = 7'b1111101;
            4'd7: seg = 7'b0000111;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
    end
endmodule
