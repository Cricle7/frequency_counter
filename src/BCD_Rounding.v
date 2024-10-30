module BCD_Rounding (
    input               clk,
    input               rst_n,
    input               start,
    input   [23:0]  BCD_in,
    input   [19:0]  BCD_out,
    output  reg         done
);
    reg                 processing;
    wire   [3:0]   hundred_thousands_in;
    wire   [3:0]   ten_thousands_in;
    wire   [3:0]   thousands_in;
    wire   [3:0]   hundreds_in;
    wire   [3:0]   tens_in;
    wire   [3:0]   units_in;
    reg [3:0]   hundred_thousands_out;
    reg [3:0]   ten_thousands_out;
    reg [3:0]   thousands_out;
    reg [3:0]   hundreds_out;
    reg [3:0]   tens_out;
    reg [3:0]   units_out;
    assign {hundred_thousands_in, ten_thousands_in, thousands_in, hundreds_in, tens_in, units_in} = BCD_in;
    assign BCD_out = {hundred_thousands_out, ten_thousands_out, thousands_out, hundreds_out, tens_out};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hundred_thousands_out <= 4'd0;
            ten_thousands_out     <= 4'd0;
            thousands_out         <= 4'd0;
            hundreds_out          <= 4'd0;
            tens_out              <= 4'd0;
            units_out             <= 4'd0;
            done                  <= 1'b0;
            processing            <= 1'b0;
        end else begin
            if (start && !processing) begin
                processing <= 1'b1;
                done       <= 1'b0;

                // 将输入直接赋值到输出
                hundred_thousands_out <= hundred_thousands_in;
                ten_thousands_out     <= ten_thousands_in;
                thousands_out         <= thousands_in;
                hundreds_out          <= hundreds_in;
                tens_out              <= tens_in;
                units_out             <= units_in;

                // 四舍五入处理
                if (units_in >= 4'd5) begin
                    // 对 tens 位加 1，并处理进位
                    if (tens_in == 4'd9) begin
                        tens_out <= 4'd0;
                        if (hundreds_in == 4'd9) begin
                            hundreds_out <= 4'd0;
                            if (thousands_in == 4'd9) begin
                                thousands_out <= 4'd0;
                                if (ten_thousands_in == 4'd9) begin
                                    ten_thousands_out <= 4'd0;
                                    if (hundred_thousands_in == 4'd9) begin
                                        hundred_thousands_out <= 4'd0;
                                        // 超出可表示范围，全部置零
                                    end else begin
                                        hundred_thousands_out <= hundred_thousands_in + 4'd1;
                                    end
                                end else begin
                                    ten_thousands_out <= ten_thousands_in + 4'd1;
                                end
                            end else begin
                                thousands_out <= thousands_in + 4'd1;
                            end
                        end else begin
                            hundreds_out <= hundreds_in + 4'd1;
                        end
                    end else begin
                        tens_out <= tens_in + 4'd1;
                    end
                end

                // 舍弃 units 位
                units_out <= 4'd0;

                done <= 1'b1;
                processing <= 1'b0;
            end else begin
                done <= 1'b0;
            end
        end
    end
endmodule
