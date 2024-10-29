module HC595_Driver #(
    parameter CNT_MAX = 2
)(
    input Clk,
    input Reset_n,
    input [15:0]Data,
    input S_EN,
    output reg SH_CP,
    output reg ST_CP,
    output reg DS
);
    
    reg [15:0]r_data;
    always@(posedge Clk)
        if(S_EN)
            r_data <= Data;

    reg [7:0]divider_cnt;//分频计数器
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        divider_cnt <= 0;
    else if(divider_cnt == CNT_MAX - 1'd1)
        divider_cnt <= 0;
    else
        divider_cnt <= divider_cnt + 1'b1;
    
    wire sck_plus;
    assign sck_plus = (divider_cnt == CNT_MAX - 1'd1);
    
    reg [5:0]SHCP_EDGE_CNT;
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        SHCP_EDGE_CNT <= 0;
    else if(sck_plus)begin
        if(SHCP_EDGE_CNT == 6'd32)
            SHCP_EDGE_CNT <= 0;
        else
            SHCP_EDGE_CNT <= SHCP_EDGE_CNT + 1'b1;
    end
        
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)begin
        SH_CP <= 0;
        ST_CP <= 0;
        DS <= 0;   
    end
    else begin
        case(SHCP_EDGE_CNT)
            0: begin SH_CP <= 0;ST_CP <= 1'd0;DS <= r_data[15];end
            1: SH_CP <= 1'd1;
            2: begin SH_CP <= 0;DS <= r_data[14];end
            3: SH_CP <= 1'd1;
            4: begin SH_CP <= 0;DS <= r_data[13];end   
            5: SH_CP <= 1'd1;
            6: begin SH_CP <= 0;DS <= r_data[12];end
            7: SH_CP <= 1'd1;
            8: begin SH_CP <= 0;DS <= r_data[11];end   
            9: SH_CP <= 1'd1;
            10: begin SH_CP <= 0;DS <= r_data[10];end
            11: SH_CP <= 1'd1;
            12: begin SH_CP <= 0;DS <= r_data[9];end  
            13: SH_CP <= 1'd1;
            14: begin SH_CP <= 0;DS <= r_data[8];end
            15: SH_CP <= 1'd1;
            16: begin SH_CP <= 0;DS <= r_data[7];end   
            17: SH_CP <= 1'd1;
            18: begin SH_CP <= 0;DS <= r_data[6];end
            19: SH_CP <= 1'd1;
            20: begin SH_CP <= 0;DS <= r_data[5];end   
            21: SH_CP <= 1'd1;
            22: begin SH_CP <= 0;DS <= r_data[4];end
            23: SH_CP <= 1'd1;
            24: begin SH_CP <= 0;DS <= r_data[3];end   
            25: SH_CP <= 1'd1;
            26: begin SH_CP <= 0;DS <= r_data[2];end
            27: SH_CP <= 1'd1;
            28: begin SH_CP <= 0;DS <= r_data[1];end
            29: SH_CP <= 1'd1;
            30: begin SH_CP <= 0;DS <= r_data[0];end
            31: SH_CP <= 1'd1;
            32: ST_CP <= 1'd1;
            default:
                begin
                    SH_CP <= 0;
                    ST_CP <= 0;
                    DS <= 0;   
                end
        endcase
    end

endmodule
