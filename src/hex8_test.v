module hex8_test(
    input Clk,
    input Reset_n,
    input [3:0]point_1,
    input [3:0]point_2,

    input [31:0]Disp_Data,
    
    output SH_CP,
    output ST_CP,
    output DS
);
    wire [7:0]SEL;
    wire [7:0]SEG;//seg[0]-a,seg[1]-b...seg[7]-h
    
    hex8_2 u_hex8_2(
        Clk,
        Reset_n,
        Disp_Data,
        SEL,
        SEG,
        point_1,
        point_2
    ); 
    wire [15:0]Data;
    assign Data = {SEG,SEL};
    
    wire S_EN;
    assign S_EN = 1;
    
    HC595_Driver HC595_Driver(
        Clk,
        Reset_n,
        Data,
        S_EN,
        SH_CP,
        ST_CP,
        DS
    );
    
endmodule
