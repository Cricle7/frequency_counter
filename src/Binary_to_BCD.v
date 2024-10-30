module Binary_to_BCD (
    input               clk,
    input               rst_n,
    input               start,
    input       [31:0]  binary_in,
    output  reg [23:0]  bcd,
    output  reg         done
);
    reg [31:0]          binary_reg;
    reg [5:0]           i;
    reg                 processing;

    reg [3:0] units;
    reg [3:0] tens;
    reg [3:0] hundreds;
    reg [3:0] thousands;
    reg [3:0] ten_thousands;
    reg [3:0] hundred_thousands;
    always @(posedge clk) begin
        if (!rst_n) begin
            processing <= 1'b0;
        end else if (start && !processing) begin
            // 初始化
            binary_reg          <= binary_in;
            done                <= 1'b0;
            processing          <= 1'b1;
            hundred_thousands   <= 0;
            ten_thousands       <= 0;
            thousands           <= 0;
            hundreds            <= 0;
            tens                <= 0;
            units               <= 0;
            i                   <= 23;
        end else if (processing) begin
            if (units >= 4'd5) 		units = units + 4'd3;
            if (tens >= 4'd5) 		tens = tens + 4'd3;
            if (hundreds >= 4'd5)	hundreds = hundreds + 4'd3;
            if(thousands >= 4'd5)       thousands = thousands + 4'd3;
            if(ten_thousands >= 4'd5)       ten_thousands = ten_thousands + 4'd3;
            if(hundred_thousands >= 4'd5)       hundred_thousands = hundred_thousands + 4'd3;
            hundred_thousands = {hundred_thousands[2:0],ten_thousands[3]};
            ten_thousands = {ten_thousands[2:0],thousands[3]};
            thousands = {thousands[2:0],hundreds[3]};
            hundreds = {hundreds[2:0],tens[3]};
            tens	 = {tens[2:0],units[3]};
            units	 = {units[2:0],binary_reg[i]};
            i <= i - 1;
            if (i == 0) begin
                // 转换完成，输出结果
                done <= 1'b1;
                processing <= 1'b0;
                bcd <= {hundred_thousands,ten_thousands,thousands,hundreds, tens, units};
            end
        end
    end 
endmodule
